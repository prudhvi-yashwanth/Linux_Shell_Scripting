## Linux File System

## `/` — Root Filesystem

- `/` is the **root of the Linux filesystem hierarchy**.
- All other directories are located under `/`.
- The command `df -h` helps check filesystem/disk usage, including the root filesystem.

### Production Angle

If `/` fills up completely and `df -h` shows `100%`, the system can become unstable.

Possible problems include:

- Applications failing to write files.
- Logs failing to be written.
- Services failing.
- Users being unable to log in.

> A full root filesystem is a critical production issue and should be monitored.

---

## `/etc` — Configuration Files

`/etc` contains **system-wide configuration files**.

### Important Files and Directories

- `/etc/passwd` — User account information.
- `/etc/shadow` — Encrypted user password information and password-related settings.
- `/etc/group` — Group information.
- `/etc/fstab` — Filesystem mount configuration.
- `/etc/hosts` — Local hostname-to-IP mappings.
- `/etc/sudoers` — Sudo permissions and configuration.
- `/etc/ssh/sshd_config` — SSH server configuration.
- `/etc/nginx/` — Nginx configuration.
- `/etc/systemd/` — Systemd-related configuration.

### Real-World Use Case

When you configure services such as **Nginx or SSH**, you commonly modify configuration files under `/etc`.

### Docker/Kubernetes Connection

Kubernetes ConfigMaps serve a similar purpose conceptually by providing configuration to containers.

A ConfigMap can be mounted as files inside a container, often under a directory such as `/etc/`.

### Interview Point

**Where would you check DNS resolution configuration on a Linux host?**

Common files:

- `/etc/resolv.conf`
- `/etc/hosts`

> `/etc/resolv.conf` contains DNS resolver configuration, while `/etc/hosts` contains local hostname mappings.

---

## `/bin` and `/sbin` — Essential Commands

Historically:

- `/bin` contains essential commands used by users and scripts, such as:
  - `ls`
  - `cp`
  - `cat`

- `/sbin` contains system administration binaries, such as:
  - `reboot`
  - `fdisk`

Modern Linux distributions may merge these directories into `/usr/bin` and `/usr/sbin` through a **usr-merge** layout.

> Do not assume `/sbin` is strictly "root only" on modern Linux systems; access is primarily controlled through permissions and capabilities.

---

## `/usr` — User Programs and Shared Software

`/usr` contains most **user-space programs, libraries, and shared data**.

Important directories:

- `/usr/bin` — Most user commands and executables.
- `/usr/sbin` — System administration commands.
- `/usr/lib` — Libraries used by programs.
- `/usr/share` — Architecture-independent shared data such as documentation, icons, and configuration templates.

### Real-World Use Case

When you install software using a package manager such as `apt`, many of its files are installed under `/usr`.

### Useful Command

    du -sh /usr/*

This helps identify which directories under `/usr` are using the most disk space.

---

## `/var` — Frequently Changing Data

`/var` contains data that **changes frequently while the system is running**.

Examples include:

- Logs
- Caches
- Mail queues
- Application data
- Database data

### Important Directory: `/var/log`

`/var/log` contains system and application logs.

Examples:

- `/var/log/syslog` — General system logs on systems using rsyslog.
- `/var/log/auth.log` — Authentication, login, and sudo-related events on Debian/Ubuntu systems.
- Service-specific log directories/files.

### Important Directory: `/var/lib`

`/var/lib` contains **persistent application and service state/data**.

Examples:

- `/var/lib/docker` — Docker's default data directory on many Linux installations.
- `/var/lib/mysql` — MySQL data directory on many traditional installations.

### Docker Connection

If Docker consumes a large amount of disk space, `/var/lib/docker` is one of the first locations to investigate.

Useful command:

    du -sh /var/lib/docker/*

> The exact Docker data location can be changed in Docker's configuration, so `/var/lib/docker` is the default/common location, not a universal rule.

### Interview Point

**Where does Docker commonly store its data on a Linux host?**

Answer:

`/var/lib/docker`

---

## `/tmp` — Temporary Files

`/tmp` is used for **temporary and short-lived files** created by applications, scripts, and users.

### Real-World Use Case

Scripts often use `/tmp` to store temporary working files.

Example:

    /tmp/app-output.txt

On many Linux systems, files under `/tmp` are cleaned automatically based on system configuration.

> On some systems, `/tmp` may be mounted as `tmpfs`, meaning it is backed by memory rather than persistent disk storage.

---

## `/opt` — Optional / Third-Party Software

`/opt` is commonly used for **optional or third-party software**.

It is useful for applications that are installed as self-contained packages rather than being distributed through the operating system's standard package layout.

### Real-World Use Case

Third-party tools and monitoring agents may install under directories such as:

    /opt/<application>

Examples can include monitoring agents or custom enterprise software.

---

## `/home` — User Home Directories

`/home` contains the home directories of regular users.

Example:

    /home/user1
    /home/user2

A user's personal files, scripts, and configuration files are usually stored here.

Examples:

- `~/.ssh/` — SSH keys and configuration.
- `~/.bashrc` — Bash shell configuration.
- Personal scripts and files.

---

## `/root` — Root User's Home Directory

`/root` is the home directory of the **root user**.

It is separate from `/home`.

### Why is `/root` separate from `/home`?

This keeps the root user's home independent from regular user home directories.

For example, if `/home` is mounted on a separate filesystem and that filesystem is unavailable, the root user can still have a working home directory under `/root`.

### Interview Point

**Why isn't root's home directory `/home/root`?**

Because `/root` is the traditional dedicated home directory for the root user and is independent of `/home`.

---

## `/proc` — Process and Kernel Information

`/proc` is a **virtual filesystem** provided by the Linux kernel.

It does not contain normal files stored permanently on disk. The kernel exposes live information through it.

Each running process has a directory:

    /proc/<PID>/

Example:

    /proc/1234/

### Useful Examples

    cat /proc/cpuinfo

Shows CPU information.

    cat /proc/meminfo

Shows memory information.

    ls /proc/1234/

Shows information associated with process `1234`.

    cat /proc/1234/status

Shows the current status of process `1234`.

### How Do `ps`, `top`, and `free` Get Information?

Many Linux monitoring tools read information exposed by the kernel through interfaces such as `/proc`.

### Docker/Kubernetes Connection

Linux containers use kernel mechanisms such as **cgroups** and namespaces.

Related resource-control information can also be exposed through interfaces under `/proc` and `/sys`.

### Interview Point

**How does `top` get process and system information?**

It reads kernel-exposed information, including data from `/proc`.

---

## `/sys` — Kernel and Hardware Information

`/sys` is another **virtual filesystem** provided by the Linux kernel.

It provides structured information about:

- Hardware devices
- Kernel subsystems
- Drivers
- Devices
- Cgroups
- Other kernel objects

### Docker/Kubernetes Connection

Linux **cgroups** are used to control and limit resources such as CPU and memory for processes and containers.

On modern Linux systems, cgroup information is commonly exposed through:

    /sys/fs/cgroup/

This is an important part of how container runtimes enforce resource limits.

### Interview Point

**How does Kubernetes enforce CPU and memory limits at the Linux OS level?**

Through **Linux cgroups**, which provide resource control for processes and containers.

---

## `/dev` — Device Files

`/dev` contains **device files** that provide an interface to hardware and kernel devices.

Examples:

- `/dev/sda` — A disk device on systems using traditional device naming.
- `/dev/null` — Discards anything written to it.
- `/dev/zero` — Provides a continuous stream of zero bytes.

### Real-World Examples

Discard errors:

    command 2>/dev/null

Write data to `/dev/null`:

    command > /dev/null

`/dev/null` is commonly used in scripts when output is not required.

---

# Quick Revision

| Directory | Purpose |
|---|---|
| `/` | Root of the entire filesystem hierarchy |
| `/etc` | System-wide configuration files |
| `/bin` | Essential user commands |
| `/sbin` | System administration commands |
| `/usr` | User programs, libraries, and shared data |
| `/var` | Frequently changing and persistent application data |
| `/tmp` | Temporary files |
| `/opt` | Optional/third-party software |
| `/home` | Regular users' home directories |
| `/root` | Root user's home directory |
| `/proc` | Virtual filesystem for process and kernel information |
| `/sys` | Virtual filesystem for kernel, hardware, and cgroup information |
| `/dev` | Device files |
