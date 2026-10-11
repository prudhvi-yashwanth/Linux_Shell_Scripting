# Linux Study Notes — Files, Links, Users, SSH, Processes, Memory, Packages, Services

These notes cover: file and path basics, hard vs soft links, switching users (`su` vs `sudo su` vs `sudo su -`), users and groups, SSH key-based login, process monitoring and signals, swap memory, package management (`apt`), and systemd services.

Default distribution: **Ubuntu** (Debian family). RHEL/CentOS/Amazon Linux differences are shown where relevant.

---

## 1. Files, Text, and Paths (the base you build on)

### Why this exists
Everything in Linux is a file or a process. Before you can debug a service, you must be able to **find, read, edit, and create files** and know **where** they live.

### Absolute vs relative paths

| Type | Starts with | Example | Meaning |
|---|---|---|---|
| Absolute | `/` | `/home/ubuntu/config.py` | Full path from root, always works from anywhere |
| Relative | `.` `..` or a name | `./config.py`, `../logs/app.log` | Depends on your current directory |

- `.` = current directory, `..` = parent directory, `~` = your home directory.
- `pwd` → print working directory (where am I?).
- **Why it matters:** cron jobs, systemd unit files, and scripts often fail because they use a relative path but run from a different working directory. **Always use absolute paths in production scripts and service files.**

### Creating and writing files

| Command | Purpose | Example |
|---|---|---|
| `touch` | Create an empty file, or update its timestamp | `touch config.py` |
| `echo "text" > file` | Write text, **overwriting** the file | `echo "hello" > welcome.txt` |
| `echo "text" >> file` | **Append** text (keeps old content) | `echo "world" >> welcome.txt` |

Real-world use: `>` in a script to write a config, `>>` to add a line to a log or an inventory file.

### Viewing files

| Command | What it does |
|---|---|
| `cat file` | Print the whole file to the screen |
| `cat -n file` | Print with line numbers (great for reading scripts) |
| `cat -E file` | Show `$` at the end of every line — reveals trailing spaces and hidden CR/LF problems |
| `cat -A file` | Show all non-printing characters (tabs as `^I`, line ends as `$`) |
| `less file` | Scroll through large files (`/search`, `n` next, `q` quit) |
| `head -n 20 file` | First 20 lines |
| `tail -n 50 file` | Last 50 lines |
| `tail -f /var/log/syslog` | **Follow** a log live — the single most used command during incidents |

`cat -E` and `cat -A` are your tools when a config file "looks correct" but the app still fails — usually a hidden `\r` from a Windows-edited file.

### Editing with vim (survival mode)

vim has modes. You start in **Normal mode**.

1. Press `i` → **Insert mode** (type text).
2. Press `Esc` → back to **Normal mode**.
3. Type `:` → **Command mode**.

| Command | Action |
|---|---|
| `:w` | Save (write) |
| `:wq` or `:x` | Save and quit |
| `:q` | Quit (fails if unsaved changes) |
| `:q!` | Quit **without** saving |
| `:w!` | Force save (e.g., read-only file when you are root) |
| `:set nu` | Show line numbers |
| `dd` | Delete a line (normal mode) |
| `yy` / `p` | Copy line / paste below |

Windows/macOS equivalent: Notepad / nano / VS Code. On a server, you only have the terminal, so `vim` or `nano` is the tool.

---

## 2. Hard Links vs Soft (Symbolic) Links

### Why this exists
You often need the "same file" in two places without duplicating data (hard link), or a convenient shortcut to a file or directory that lives elsewhere (soft link).

Every file on disk has an **inode** — a small data structure holding metadata (permissions, owner, size, and pointers to the actual data blocks). The **filename is just a pointer to an inode**. `ls -li` shows the inode number.

```
Hard link:   name1 ──┐
                     ├──► inode 12345 ──► data blocks
             name2 ──┘

Soft link:   name1 ──► inode 99999 ──► "/path/to/name2" (just a path string)
```

### Comparison

| Feature | Hard link `ln target link` | Soft/symbolic link `ln -s target link` |
|---|---|---|
| Points to | The same inode | A path (a text pointer) |
| Same inode number? | Yes | No (different inode) |
| Across filesystems? | No | Yes |
| Can link a directory? | No | Yes |
| If original deleted | Data still accessible | Link breaks ("dangling"/broken link) |
| Created with | `ln file link` | `ln -s /path/file link` |
| Typical use | Backup snapshot trick, dedup within one FS | Shortcuts, version switching, config pointers |

### Practical examples

```bash
# Soft link the file config.py into /tmp
ln -s /home/ubuntu/config.py /tmp/

ls -l /tmp/config.py
# lrwxrwxrwx 1 ubuntu ubuntu 24 ... /tmp/config.py -> /home/ubuntu/config.py
#  ^ the 'l' means it is a link

# Hard link
ln /home/ubuntu/config.py /home/ubuntu/config_hard.py
ls -li /home/ubuntu/config.py /home/ubuntu/config_hard.py
# Same inode number → same file, two names
```

### Real production uses
- `/etc/nginx/sites-enabled/app` → symlink → `/etc/nginx/sites-available/app` (enable/disable a site by creating/removing a link).
- **Atomic deploys:** `/var/www/current` → symlink → `/var/www/releases/2026-10-02`. Switch the symlink and the new version is live instantly; rollback = point it back.
- Java/Python version switching: `ln -s /usr/lib/jvm/java-21 /opt/java/current`.

### Gotchas
- Prefer **absolute paths** for soft links. Relative links break when the link is moved or accessed from a different directory.
- A broken symlink still exists. Find them: `find /path -xtype l`.
- Deleting a symlink never deletes the target. Deleting a hard link's *name* only removes data when the **last** link is gone (link count reaches 0).

---

## 3. Switching Users: `su` vs `sudo su` vs `sudo su -`

### Why this exists
Servers must run with **least privilege**. You log in as a normal user and only become root for the exact tasks that need it. Understanding these four commands prevents both "why is my PATH wrong?" bugs and serious security mistakes.

### Definitions

| Command | What it does |
|---|---|
| `su` | Switch user. Asks for the **target user's password** (root's password for `su`). **Non-login shell.** |
| `su -` | Same, but a **login shell**. Asks for the target user's password. |
| `sudo su` | Runs `su` under `sudo`. Asks for **your own password**. Non-login shell as root. |
| `sudo su -` | Runs `su -` under `sudo`. Asks for **your own password**. Login shell as root. |

### The critical difference: login shell vs non-login shell

| | Non-login (`su`, `sudo su`) | Login (`su -`, `sudo su -`) |
|---|---|---|
| Reads `/etc/profile`, `~/.bash_profile`? | No | Yes |
| Environment variables | Kept from your session | Fully replaced with the target user's |
| `PATH` | Your user's PATH (often missing `/sbin`, `/usr/sbin`) | Target user's PATH (includes `/sbin`, `/usr/sbin`) |
| Current directory | Unchanged (e.g., `/home/ubuntu`) | Changes to target user's home (`/root`) |
| `$HOME` | May still be your home | Target user's home |

**Symptom to remember:** If `ifconfig`, `ip`, `reboot`, or `systemctl` says *"command not found"* after `sudo su`, it is because `/usr/sbin` and `/sbin` are missing from your `PATH`. Use `sudo su -` instead.

### Safer modern equivalents

| Old habit | Better | Why |
|---|---|---|
| `sudo su` | `sudo -s` | Same non-login shell, cleaner, no nested `su` process |
| `sudo su -` | `sudo -i` | Same login shell behaviour |
| `sudo su -` then run one command | `sudo <command>` | Least privilege, and the command is logged in `/var/log/auth.log` |

### Production rule
> **Do not live inside a root shell.** Use `sudo <command>` for the one command that needs root. Full root shells skip the sudo audit trail, keep a long-lived privileged session open, and are a classic attacker target. Disable direct root SSH login: `PermitRootLogin no`.

### Handy sudo options
```bash
sudo -l              # what am I allowed to run as sudo? (first thing to check when sudo fails)
sudo -u postgres psql   # run a command as another non-root user
sudo -k              # forget the cached sudo password
visudo               # safely edit /etc/sudoers (checks syntax before saving)
```
Sudo permissions live in `/etc/sudoers` and, better, in drop-in files under `/etc/sudoers.d/`.

---

## 4. Users and Groups

### Why this exists
Every process runs as a user and belongs to groups. Permissions are checked against that user's UID/GID. Access control, auditing, and least privilege all start here.

### The four key files

| File | Holds | Notes |
|---|---|---|
| `/etc/passwd` | User accounts | World-readable. Format: `name:x:UID:GID:comment:home:shell` |
| `/etc/shadow` | Password hashes, expiry | Readable only by root. Never edit by hand. |
| `/etc/group` | Groups and their members | Format: `group:x:GID:member1,member2` |
| `/etc/gshadow` | Group passwords/admins | Root-only |

UID conventions on Ubuntu: `0` = root, `1–999` = system/service accounts, `1000+` = normal human users. In containers, the app user is often UID `1000` or higher and has no entry in `/etc/passwd` (that causes "whoami: cannot find name" errors).

### Managing users

| Command | Purpose | Example |
|---|---|---|
| `id <user>` | Show UID, primary group, all groups | `id bharath` |
| `useradd -m <user>` | Create user with a home directory (low-level) | `useradd -m linuxuser` |
| `adduser <user>` | Friendly wrapper on Debian/Ubuntu; creates home, copies skeleton files, prompts for password | `adduser linuxuser` |
| `usermod -aG sudo <user>` | **Append** to a supplementary group | `usermod -aG sudo linuxuser` |
| `usermod -g dev <user>` | Change the **primary** group | `usermod -g dev bharath` |
| `usermod -G dev,marketing <user>` | Set supplementary groups (**replaces** the list — dangerous!) | `usermod -G dev,marketing tom` |
| `passwd <user>` | Set/change a password | `passwd linuxuser` |
| `userdel <user>` | Delete the user, keeps home directory | `userdel tom` |
| `userdel -r <user>` | Delete user **and** home directory + mail spool | `userdel -r tom` |

> **Most common production mistake:** using `usermod -G` instead of `usermod -aG`. Without `-a`, the user is **removed** from all other supplementary groups — including `sudo`. Always use `-aG`.

### Managing groups

| Command | Purpose | Example |
|---|---|---|
| `groupadd <group>` | Create a group | `groupadd dev` |
| `groupdel <group>` | Delete a group (must not be anyone's primary group) | `groupdel dev` |
| `gpasswd -a <user> <group>` | Add user to group (appends) | `gpasswd -a tom dev` |
| `gpasswd -d <user> <group>` | Remove user from group | `gpasswd -d tom dev` |
| `getent group <group>` | Look up a group — works for **local, LDAP, and AD** accounts | `getent group dev` |
| `getent passwd <user>` | Same for users | `getent passwd bharath` |

**Why `getent` instead of `cat /etc/group`?** `cat /etc/group` shows only **local** accounts. `getent` uses NSS (Name Service Switch) and also queries directory services like AD/LDAP. On a corporate server, `cat /etc/passwd` will not show domain users — `getent passwd user@corp.example.com` will.

### Group membership changes need a re-login
Group membership is applied at login. After `usermod -aG`, the user must log out and back in (or run `newgrp <group>` for the current shell) before the new group takes effect. `id` in the old session will still show the old groups.

### Enterprise identity: Active Directory / Entra ID and SSSD

- **AD (Active Directory)** — Microsoft's directory service; the **Domain Controller (DC)** authenticates users and machines in a Windows domain. **Entra ID** (formerly Azure AD) is the cloud equivalent.
- **SSSD (System Security Services Daemon)** — the Linux daemon that lets a server authenticate against AD/LDAP/Kerberos and cache credentials. Config: `/etc/sssd/sssd.conf`.
- Joining a domain on Ubuntu/RHEL typically uses `realmd`, `adcli`, `sssd`, and Kerberos (`kinit`, `klist`).

```bash
realm discover corp.example.com       # is the domain reachable?
sudo realm join corp.example.com -U admin   # join the domain
id user@corp.example.com              # verify a domain user resolves
getent passwd user@corp.example.com   # verify NSS is talking to SSSD
systemctl status sssd                 # SSSD daemon health
journalctl -u sssd -n 100             # SSSD logs (first place to look on login failures)
```

**DevSecOps relevance:** domain-joined Linux servers give you centralized authentication, MFA via the IdP, and a single place to revoke access. Local accounts become the exception, not the rule.

### Admin privilege groups
- Ubuntu/Debian: `sudo` group. RHEL/CentOS/Amazon Linux: `wheel` group.
- Always edit sudo rules with `visudo` — it validates syntax. A broken `/etc/sudoers` can lock everyone (including you) out of sudo.

---

## 5. SSH Keys and Passwordless Login

### Why this exists
Passwords are guessable, shared, and phishable. **Public-key authentication** proves identity without sending a secret over the wire, and it's the foundation for automation (Ansible, CI/CD, `scp`, `rsync`, Git).

### How it works (simple analogy)
- The **private key** is your house key. It never leaves your machine.
- The **public key** is a padlock you can hand out freely. It goes into `~/.ssh/authorized_keys` on the server.
- The server sends a challenge; only the matching private key can answer it. The key itself is never transmitted.

### Generating a key pair

```bash
ssh-keygen -t rsa -b 4096 -f linuxuser
```

| Flag | Meaning |
|---|---|
| `-t` | Key type: `rsa`, `ecdsa`, or `ed25519` |
| `-b` | Bit size (RSA: 2048 minimum, **4096 recommended**; `ed25519` ignores `-b`) |
| `-f` | Output filename (base name) |
| `-C` | Comment, usually `you@host` — helps you identify keys later |

This creates **two files**:
- `linuxuser` — the **private** key. Keep it secret, `chmod 600`, never commit it to Git.
- `linuxuser.pub` — the **public** key. Copy this to servers.

> **Modern recommendation:** prefer `ssh-keygen -t ed25519 -C "you@host"`. It's faster and stronger than RSA at equivalent security. Use RSA 4096 only when you must interoperate with old systems.

### PEM vs OpenSSH key formats
`.pem` is a **container/encoding format** (Base64 with `-----BEGIN ...-----` headers), not a key type. Both RSA and EC keys can be stored in PEM. If you rename the private key to `private.pem`, that's fine — you then tell SSH which file to use:

```bash
ssh -i private.pem linuxuser@server
```

You can also convert between formats:
```bash
ssh-keygen -p -m PEM -f linuxuser     # rewrite an OpenSSH key in PEM format
```
**Permissions matter regardless of the filename.** `chmod 600 private.pem`. OpenSSH refuses to use a private key that others can read: *"Permissions 0644 are too open."*

### Setting up passwordless login — step by step

**Step 1 — Create the Linux user on the server (s1):**
```bash
sudo adduser linuxuser            # friendly, creates home + password
# or:
sudo useradd -m linuxuser
sudo passwd linuxuser
```
Give it sudo if it needs admin rights:
```bash
sudo usermod -aG sudo linuxuser
id linuxuser                      # verify
```

**Step 2 — Install the public key on the server, in that user's account:**
```bash
sudo su - linuxuser               # login shell, so $HOME is correct
mkdir -p ~/.ssh
chmod 700 ~/.ssh
vim ~/.ssh/authorized_keys        # paste the contents of linuxuser.pub
chmod 600 ~/.ssh/authorized_keys
exit
```

**Correct permissions (SSH is strict about this):**

| Path | Mode |
|---|---|
| `~` (home directory) | `755` or stricter (not group/world-writable) |
| `~/.ssh` | `700` |
| `~/.ssh/authorized_keys` | `600` |
| Private key (on client) | `600` |

**Step 3 — Connect:**
```bash
ssh -i linuxuser linuxuser@server-ip
```

**Shortcut:** `ssh-copy-id -i linuxuser.pub linuxuser@server-ip` does step 2 for you and sets the correct permissions.

### Hardening the SSH server (`/etc/ssh/sshd_config`)
```
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
KbdInteractiveAuthentication no
AllowUsers linuxuser deploy
MaxAuthTries 3
X11Forwarding no
Port 2222               # optional, reduces noise but is not real security
```

Apply safely — **always test before reloading**, or you can lock yourself out:
```bash
sudo sshd -t                 # syntax check
sudo systemctl reload ssh    # Ubuntu service name is 'ssh'; RHEL uses 'sshd'
```
Keep your current session open until you have verified a fresh login works in a second terminal.

### Troubleshooting SSH

| Symptom | Check |
|---|---|
| `Permission denied (publickey)` | Is the public key in the right user's `authorized_keys`? Are permissions 700/600? |
| `Permissions 0644 ... too open` (client) | `chmod 600` the private key |
| Still asked for password | `PasswordAuthentication yes` may be off on your side / key not accepted. Run `ssh -v user@host` |
| `Connection refused` | Is `sshd` running? `systemctl status ssh`. Is the firewall/security group open on the port? |
| `Connection timed out` | Network path problem — security group, firewall, routing. Not an SSH config problem. |
| `Host key verification failed` | Server was rebuilt. Remove the old entry: `ssh-keygen -R host` |
| `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED` | Same as above, but investigate first — it can indicate a man-in-the-middle attack. |

Where the logs are:
```bash
ssh -v user@host                 # client-side verbose (use -vvv for more)
journalctl -u ssh -n 100         # server-side, on systemd distros
tail -f /var/log/auth.log        # Ubuntu/Debian
tail -f /var/log/secure          # RHEL family
```

### Automation and DevSecOps connections
- **Ansible** uses SSH keys exclusively — no agent required on the target.
- **CI/CD** (GitHub Actions, GitLab CI) injects a **deploy key** or SSH key from a secret store to push to servers or to Git.
- **Containers:** never bake private keys into an image. Mount them or inject them at runtime.
- **Best practice:** one key pair per person per purpose, passphrase-protected, cached with `ssh-agent`. Rotate keys. Use a **bastion/jump host** (`ssh -J bastion target`) instead of exposing every server. Better still, use short-lived certificates (Teleport, Vault, AWS SSM Session Manager) rather than long-lived static keys.

---

## 6. Processes, `top`, and Signals

### Why this exists
When a server is slow, the first question is always: **what is eating CPU, memory, or I/O, and who owns it?** When a service must pick up a config change without dropping connections, you need the right **signal**.

### Reading `top`

```
top - 14:22:31 up 12 days,  3:14,  2 users,  load average: 0.52, 0.48, 0.41
Tasks: 187 total,   1 running, 186 sleeping,   0 stopped,   0 zombie
%Cpu(s):  3.2 us,  1.1 sy,  0.0 ni, 94.6 id,  1.0 wa,  0.0 hi,  0.1 si,  0.0 st
MiB Mem :   3936.0 total,    412.3 free,   1204.5 used,   2319.2 buff/cache
MiB Swap:   2048.0 total,   2048.0 free,      0.0 used.   2400.1 avail Mem
```

**CPU field meanings:**

| Field | Meaning | Why you care |
|---|---|---|
| `us` | user space — your applications | High `us` = app is CPU-bound. Profile the app. |
| `sy` | system/kernel space | High `sy` = too many syscalls, heavy network/disk I/O, or container/VM overhead |
| `ni` | user space, low priority (nice) | Batch jobs |
| `id` | idle | Should be high on a healthy server |
| `wa` | **iowait** — CPU idle while waiting on disk/network | High `wa` = storage is the bottleneck, not CPU. Check `iostat`. |
| `hi` | hardware interrupts | High = device/driver issue |
| `si` | software interrupts | High `si` = heavy network traffic |
| `st` | **steal** — time the hypervisor took from your VM | High `st` in a cloud VM = a noisy neighbour. Talk to your cloud provider. |

**Load average** = number of processes runnable or waiting on I/O, averaged over 1, 5, and 15 minutes. Compare it to the **number of CPU cores**. Load 4 on a 4-core box is fully busy; load 8 means work is queueing.

**Keys inside `top`:**

| Key | Action |
|---|---|
| `P` (capital) | Sort by **CPU** usage |
| `M` (capital) | Sort by **memory** usage |
| `T` | Sort by running time |
| `1` | Toggle per-CPU view |
| `c` | Show the full command line |
| `k` | Kill a process (asks for PID and signal) |
| `r` | Renice a process |
| `u` | Filter by user |
| `h` | Help |
| `q` | Quit |

**Modern alternatives:**
```bash
htop                                   # interactive, colour, mouse, tree view
ps aux --sort=-%cpu | head -n 10       # top CPU consumers, one-shot
ps aux --sort=-%mem | head -n 10       # top memory consumers
pidstat -u 1 5                         # per-process CPU over time
vmstat 1 5                             # CPU + memory + I/O in one view
iostat -xz 1                           # disk saturation
```

### Signals

```bash
kill -l                 # list all signals and their numbers
kill -<signal> <PID>
kill <PID>              # default is SIGTERM (15)
pkill -f "python app.py"   # kill by name/pattern
killall nginx              # kill by process name
```

| Signal | Number | Meaning | Typical use |
|---|---|---|---|
| `SIGHUP` | 1 | Hang up / **reload configuration** | `kill -1 <PID>` → Nginx, Apache, sshd reload config **without dropping connections** |
| `SIGINT` | 2 | Interrupt | What `Ctrl+C` sends |
| `SIGQUIT` | 3 | Quit + core dump | `Ctrl+\` |
| `SIGKILL` | 9 | **Uncatchable, immediate termination** | Last resort. No cleanup, no log flush, no connection draining. |
| `SIGTERM` | 15 | Polite request to stop (default) | Let the process clean up and exit gracefully |
| `SIGSTOP` / `SIGCONT` | 19 / 18 | Pause / resume | Debugging |

**The SIGHUP reload pattern — why it matters in production:**
```bash
kill -1 $(cat /var/run/nginx.pid)
# or, cleaner:
sudo systemctl reload nginx
```
The master process re-reads its config, spawns new workers, and retires old ones. **Existing connections finish; nothing drops; no downtime.** This is zero-downtime config reloading, and it's why `reload` beats `restart` in a load-balanced environment.

**Kill order of operations:**
1. `SIGTERM` (15) — ask nicely, let it clean up.
2. Wait. Check it's gone: `ps -p <PID>`.
3. Only then `SIGKILL` (9) — and understand that you may leave stale lock files, half-written data, or unclosed sockets.

In Kubernetes, this maps directly: on pod termination the kubelet sends `SIGTERM` and waits for `terminationGracePeriodSeconds` (default 30s), then sends `SIGKILL`.

### Real scenarios
- **"Server is slow"** → `top`, check load average vs cores, check `wa` (I/O vs CPU), then `ps aux --sort=-%cpu`.
- **"Service won't start"** → `systemctl status <svc>`, `journalctl -u <svc> -n 100`.
- **"Zombie processes"** → a zombie is a finished child whose parent hasn't reaped it. Fix the parent, not the zombie (`kill -9` does nothing to a zombie).

---

## 7. Memory and Swap

### Why this exists
When RAM is exhausted, the kernel either moves cold pages to **swap** (slow) or kills a process with the **OOM killer** (brutal). Knowing which is happening tells you whether to add RAM, tune the app, or set limits.

### What swap is
**Swap** is disk space the kernel uses as overflow for RAM. Think of RAM as your desk and swap as a filing cabinet in the basement: you *can* put things there, but fetching them is far slower. Swap prevents immediate crashes but a server that swaps heavily is a server performing badly.

### Checking memory and swap

```bash
free -h                  # human-readable total/used/free + swap
swapon --show            # active swap devices/files and priorities
cat /proc/swaps          # same, kernel view
cat /proc/meminfo        # detailed: MemAvailable, SwapTotal, SwapFree, Dirty
vmstat 1 5               # si/so columns = swap in/out per second
```

**Key columns in `free -h`:** ignore `free`; watch **`available`** (memory the kernel estimates apps can actually use, including reclaimable cache) and the **Swap used** figure.

### How swap works (as deep as you need)
- The kernel divides memory into **pages** (usually 4 KB).
- Under pressure, it picks least-recently-used pages and writes them to swap.
- `vm.swappiness` (0–100, Ubuntu default **60**) controls how eagerly the kernel swaps. Lower = prefer dropping caches; higher = prefer swapping. **Servers commonly use 10**, and Kubernetes nodes historically set **0**.
- When memory is truly exhausted and swap is full, the **OOM killer** selects and kills a process based on an `oom_score` (higher = more likely to die). Check with:
  ```bash
  dmesg -T | grep -i "killed process"
  journalctl -k | grep -i oom
  ```

### Creating a swap file (Ubuntu)

```bash
# 1. Create a 2 GB file
sudo fallocate -l 2G /swapfile
# fallback if fallocate isn't supported on your FS:
# sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

# 2. Lock down permissions — root only
sudo chmod 600 /swapfile

# 3. Format it as swap
sudo mkswap /swapfile

# 4. Activate it
sudo swapon /swapfile

# 5. Verify
swapon --show
free -h

# 6. Make it persistent across reboots
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

Tune swappiness:
```bash
sudo sysctl -w vm.swappiness=10                       # runtime
echo 'vm.swappiness=10' | sudo tee /etc/sysctl.d/99-swap.conf   # persistent
```

### ZRAM (modern alternative)
Ubuntu ships **zram** on many images: instead of swapping to slow disk, it compresses pages in RAM. Great for low-memory VMs and desktops. Check with `zramctl`.

### Swap and containers/Kubernetes
- Kubernetes historically **required swap off** because the scheduler and memory limits assume real memory accounting. Recent kubelet versions support swap (alpha/beta), but most production clusters still run with swap disabled (`swapoff -a`).
- Containers use the host's swap unless you set `--memory-swap`.
- **Recommendation for K8s nodes:** `sudo swapoff -a` and comment out swap in `/etc/fstab`, then rely on requests/limits and the eviction mechanism.

### RHEL/CentOS difference
RHEL typically uses an **LVM swap logical volume** rather than a file. Check with `lsblk` and `swapon --show`. Extending it means extending the LV: `lvextend` → `mkswap` → `swapon`. RHEL 9 also defaults to **zram** on some profiles.

### Troubleshooting memory problems

| Symptom | Commands |
|---|---|
| Which process is using memory? | `ps aux --sort=-%mem \| head` , `smem`, `top` then `M` |
| Memory leak suspicion | Watch RSS over time: `ps -o pid,rss,cmd -p <PID>` repeatedly, or `pidstat -r 5` |
| OOM kills | `dmesg -T \| grep -i oom`, `journalctl -k \| grep oom` |
| Heavy swapping | `vmstat 1` → look at `si`/`so`. If non-zero and sustained, you're in trouble. |
| Container hitting limits | `docker stats`, `kubectl top pod`, check cgroup limits in `/sys/fs/cgroup/` |

---

## 8. Package Management with `apt` (Debian/Ubuntu)

### Why this exists
Servers must be patched. Package managers give you verified binaries, dependency resolution, version pinning, and a repeatable way to install software — the foundation of configuration management and container image builds.

### `apt` vs `apt-get`
`apt` is the modern, user-friendly front end (progress bars, colour, sensible defaults) intended for interactive use. `apt-get` is the older, script-stable interface. **In scripts and Dockerfiles, prefer `apt-get`** because its output and behaviour are guaranteed stable. Same for `apt-cache` vs the newer `apt` subcommands.

### Core workflow

```bash
sudo apt update                 # refresh the package INDEX from repositories
sudo apt upgrade                # upgrade installed packages (no removals)
sudo apt full-upgrade           # upgrade, allowing removals if dependencies require
sudo apt install nginx          # install
sudo apt install nginx=1.24.0-1ubuntu1   # install an exact version
```

> **`apt update` ≠ `apt upgrade`.** `update` refreshes the catalogue. `upgrade` installs newer versions. Running `upgrade` on a stale index does nothing useful.

### Checking versions

```bash
nginx -v                # short version
nginx --version         # full version + build flags
apt list -a nginx       # ALL available versions (installed + every repo version)
apt-cache policy nginx  # which version is installed, which is a candidate, and from where
dpkg -l | grep nginx    # is it installed, and at what version
```

### Holding a version (freeze upgrades)

```bash
sudo apt-mark hold nginx       # stop automatic upgrades for nginx
sudo apt-mark showhold         # list held packages
sudo apt-mark unhold nginx     # release it — automatic upgrades resume
```

**Why hold:** you've validated version 1.24 against your app, and 1.26 breaks it. Hold prevents an unattended-upgrade from taking production down. **Then schedule the upgrade deliberately** — a hold is a delay, not a fix. Track holds so you don't silently fall behind on security patches.

### Removing packages — know the difference

| Command | Removes binaries | Removes config | Use when |
|---|---|---|---|
| `apt remove nginx` | Yes | **No** (config stays) | You may reinstall and want your config back |
| `apt purge nginx` | Yes | **Yes** | Full clean removal, or fixing a corrupted config |
| `apt autoremove` | Unused dependencies | — | Cleaning up after removals |
| `apt autoremove --purge` | Unused deps + their config | Yes | Full cleanup |

```bash
sudo apt remove nginx -y        # -y = answer "yes" to the prompt (scripts/CI)
sudo apt purge nginx -y
sudo apt autoremove -y
```

### Useful extras

```bash
apt search <term>              # search available packages
apt show nginx                 # detailed metadata, dependencies, homepage
apt-cache depends nginx        # what nginx needs
apt-cache rdepends nginx       # what needs nginx
dpkg -L nginx                  # list every file a package installed
dpkg -S /usr/sbin/nginx        # which package owns this file
apt-get clean                  # clear downloaded .deb cache in /var/cache/apt/archives
apt-get -f install             # fix a broken dependency state
```

### RHEL / CentOS / Amazon Linux equivalents

| Ubuntu (apt) | RHEL family (dnf/yum) |
|---|---|
| `apt update` | `dnf makecache` / `dnf check-update` |
| `apt upgrade` | `dnf upgrade` |
| `apt install pkg` | `dnf install pkg` |
| `apt remove pkg` | `dnf remove pkg` |
| `apt purge pkg` | `dnf remove pkg` then delete `/etc/pkg/` manually |
| `apt list -a pkg` | `dnf --showduplicates list pkg` |
| `apt-mark hold pkg` | `dnf versionlock add pkg` (needs the `versionlock` plugin) |
| `apt autoremove` | `dnf autoremove` |
| `apt-cache policy pkg` | `dnf info pkg` |
| `dpkg -l` | `rpm -qa` |
| `dpkg -L pkg` | `rpm -ql pkg` |

### Automation and security angle
- **Unattended upgrades** (`unattended-upgrades` on Ubuntu, `dnf-automatic` on RHEL) apply **security** patches automatically. Configure it, don't just install it.
- **Repositories** are defined in `/etc/apt/sources.list` and `/etc/apt/sources.list.d/`. Treat repo GPG keys as secrets-adjacent: verify fingerprints.
- **In Dockerfiles:**
  ```dockerfile
  RUN apt-get update && apt-get install -y --no-install-recommends nginx \
      && rm -rf /var/lib/apt/lists/*
  ```
  One `RUN` line, `--no-install-recommends` to shrink the image, and clean the index to keep layers small.
- **CI/CD:** scan images and hosts for vulnerable package versions (`trivy`, `grype`, `apt list --upgradable`). Patching cadence is a core SRE/DevSecOps metric.

---

## 9. systemd and Service Management

### Why this exists
systemd is PID 1 on modern Linux: it starts services in the right order, restarts them on failure, captures their logs, and manages dependencies. Almost every production troubleshooting session starts with `systemctl status` and `journalctl`.

### Listing services

```bash
systemctl list-unit-files --type=service     # all service units + enabled/disabled state
systemctl list-units --type=service          # currently loaded/active services
systemctl list-units --type=service --all    # include inactive
systemctl --failed                           # services that failed to start — check this first
```

**States in `list-unit-files`:**

| State | Meaning |
|---|---|
| `enabled` | Starts automatically at boot |
| `disabled` | Does **not** start at boot (can still be started manually) |
| `static` | Cannot be enabled directly; pulled in by another unit |
| `masked` | Completely blocked — cannot even be started manually. Used to hard-disable a service. |
| `indirect` | Enabled only if another unit is enabled |

**`enabled` and `active` are different things.** `enabled` = will start at boot. `active` = running right now. A service can be `disabled` and `active` (you started it by hand), or `enabled` and `inactive` (it failed).

### Day-to-day service control

```bash
sudo systemctl start nginx
sudo systemctl stop nginx
sudo systemctl restart nginx        # stop + start — drops connections
sudo systemctl reload nginx         # re-read config, keep serving — preferred in production
sudo systemctl reload-or-restart nginx   # reload if supported, else restart
sudo systemctl enable nginx         # start at boot
sudo systemctl disable nginx
sudo systemctl enable --now nginx   # enable AND start in one step
sudo systemctl mask nginx           # block it entirely
sudo systemctl unmask nginx
```

### Checking status

```bash
systemctl status nginx              # active state, PID, recent logs, exit codes
systemctl is-active nginx           # for scripts: prints 'active' or 'inactive'
systemctl is-enabled nginx          # for scripts: 'enabled'/'disabled'
systemctl show nginx                # every property systemd knows about the unit
systemctl cat nginx                 # print the unit file contents (all overrides merged)
```

### Logs with journalctl

```bash
journalctl -u nginx                 # all logs for this unit
journalctl -u nginx -n 100          # last 100 lines
journalctl -u nginx -f              # follow live
journalctl -u nginx --since "1 hour ago"
journalctl -u nginx --since today --priority=err
journalctl -p err -b                # all errors since last boot
journalctl -k                       # kernel messages (dmesg equivalent)
journalctl --disk-usage
sudo journalctl --vacuum-time=7d    # keep only 7 days of logs
```

### Writing a unit file (where you'll actually use this)

Locations, in order of precedence:
- `/etc/systemd/system/` — **yours**, highest priority
- `/run/systemd/system/` — runtime
- `/usr/lib/systemd/system/` — distribution packages (Debian/Ubuntu)
- `/lib/systemd/system/` — often a symlink to the above

Example `/etc/systemd/system/myapp.service`:
```ini
[Unit]
Description=My Python API
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=appuser
Group=appuser
WorkingDirectory=/opt/myapp
EnvironmentFile=/etc/myapp/env
ExecStart=/opt/myapp/venv/bin/python /opt/myapp/app.py
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

Apply changes:
```bash
sudo systemctl daemon-reload     # REQUIRED after editing any unit file
sudo systemctl enable --now myapp
```

### Security hardening in unit files (DevSecOps)
```ini
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/var/lib/myapp
CapabilityBoundingSet=CAP_NET_BIND_SERVICE
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX
```
These use kernel namespaces and seccomp to shrink what the service can do if compromised. Verify with `systemd-analyze security myapp`.

### Reliability settings (SRE)
- `Restart=on-failure` + `RestartSec` → automatic recovery from crashes.
- `StartLimitBurst` / `StartLimitIntervalSec` → stop restart loops from hammering the box.
- `LimitNOFILE` → **fixes "too many open files"** errors without editing `/etc/security/limits.conf`.
- **Timers** replace cron: `myjob.timer` + `myjob.service`, with logging in the journal and `OnCalendar=` schedules. Check with `systemctl list-timers`.

### RHEL/CentOS differences
- Use `systemctl` the same way, but service names differ: `sshd` (not `ssh`), `firewalld` (not `ufw`), `chronyd` (not `systemd-timesyncd`).
- SELinux is enforcing by default: a service may fail to read a file even with correct Unix permissions. Check `ausearch -m avc -ts recent` and `getenforce`.

### Troubleshooting services — step by step

1. `systemctl status <svc>` — exit code, "Active:" line, last few log lines.
2. `journalctl -u <svc> -n 100 --no-pager` — full error.
3. `systemctl cat <svc>` — is there an override you forgot about?
4. Check config syntax with the service's own tool (`nginx -t`, `sshd -t`, `named-checkconf`).
5. Check permissions and ownership of config/data paths. **Especially with SELinux/AppArmor.**
6. Check the listening port: `ss -tlnp | grep <port>`. Is something else already on it?
7. Check limits: `systemctl show <svc> | grep -i limit`.
8. Check the binary runs manually as the service user: `sudo -u appuser /opt/myapp/app.py`.
9. `systemctl daemon-reload` if you edited the unit file.
10. Escalate: `strace -f -p <PID>` or `perf` if it's a deeper problem.

Common errors and fixes:

| Error | Likely cause / fix |
|---|---|
| `Unit not found` | Wrong name, or you didn't run `daemon-reload` after creating the file |
| `Job for X failed because the control process exited with error code` | The `ExecStart` command failed — read `journalctl -u X` |
| `Address already in use` | Another process holds the port: `ss -tlnp \| grep :80` |
| `Permission denied` on a file | Check ownership, then SELinux/AppArmor |
| `Start request repeated too quickly` | Restart loop hit the rate limit. Fix the root cause, then `systemctl reset-failed X` |
| `Failed to start ... Unit is masked` | `systemctl unmask X` |

---

## 10. Putting It Together — How These Topics Connect

| Tool | Docker | Kubernetes | CI/CD | Cloud / IaC |
|---|---|---|---|---|
| Users & groups | Container runs as UID 1000; `USER` in Dockerfile | `securityContext.runAsUser`, `runAsNonRoot` | Pipeline runners run as a service user | Ansible `user` module; Terraform creates IAM users, not Linux users |
| SSH keys | Never baked into images; mounted or injected | Node SSH for debugging; `kubectl exec` is preferred | Deploy keys stored as CI secrets | Bastion hosts, SSM Session Manager, `ssh -J` |
| `top` / signals | `docker stats`; `SIGTERM` → grace period → `SIGKILL` | `kubectl top`, liveness probes, `terminationGracePeriodSeconds` | — | CloudWatch/Cloud Monitoring for host metrics |
| Swap | cgroup memory limits; swap off in K8s | `swapoff -a`; rely on requests/limits + eviction | — | Instance type sizing; avoid swap for databases |
| apt | `apt-get` in Dockerfile, one layer, cleaned cache | Image scanning in admission controllers | Patch cadence, `trivy`/`grype` in pipeline | Ansible `apt` module with `state: latest` (caution) |
| systemd | Containers usually run one process, **no systemd** (unless you use `systemd` as PID 1 deliberately) | systemd is replaced by kubelet + manifests | Systemd units can be templated with Ansible | `systemctl` inside cloud-init user-data |
| Links | Bind mounts and `COPY` for configs; symlinks for version switching | ConfigMaps mounted at paths | Symlink-based atomic deploys | Symlink rollback strategies |

**The unifying idea:** Linux fundamentals are the substrate. Kubernetes schedules processes, but they're still Linux processes with UIDs, cgroups, signals, and file descriptors. Docker packages filesystems, but they're still mount namespaces and overlayfs. Every "cloud-native" abstraction eventually asks you a Linux question — and that's the interview.

---

## 11. Common Mistakes and Best Practices

| Mistake | Correct approach |
|---|---|
| Using `usermod -G` instead of `-aG` | Always `usermod -aG` to append; `-G` replaces |
| Using `sudo su` when `sudo -i` or `sudo <cmd>` is intended | Prefer `sudo <cmd>` for auditability; `sudo -i` when you truly need a root shell |
| "Command not found" after `sudo su` | You're in a non-login shell. Use `sudo su -` or `sudo -i`. |
| `chmod 777` to fix permissions | Find the actual owner/group mismatch, or use ACLs (`setfacl`) |
| World-readable private SSH keys | `chmod 600` the key, `700` on `~/.ssh`, `600` on `authorized_keys` |
| `cat /etc/passwd` to check domain users | Use `getent passwd <user>` — it queries NSS/LDAP/AD |
| Deleting a user without `-r`, leaving orphaned files | `userdel -r` when the home directory isn't needed |
| `kill -9` as first resort | `SIGTERM` (15) first, wait, then `SIGKILL` (9) |
| Restarting a service to apply config | `reload` (or `SIGHUP`) to avoid dropping connections |
| Editing a unit file and forgetting `daemon-reload` | Always `systemctl daemon-reload` after editing |
| Running `apt upgrade` without `apt update` first | `apt update && apt upgrade` |
| Assuming `remove` also removes config | Use `purge` for a full removal |
| Holding a package forever | Track holds and schedule the upgrade — patches matter |
| A relative symlink | Use absolute paths in `ln -s` |
| Editing `/etc/sudoers` directly | Always use `visudo` |
| Leaving `PermitRootLogin yes` and `PasswordAuthentication yes` | Harden `sshd_config`; test with `sshd -t` before reloading |
| Setting swap to 0 on all servers | Tune `vm.swappiness=10` (or disable swap only where the workload requires it, e.g., K8s nodes and databases) |
| Ignoring `wa` in `top` and blaming the app | High `wa` means storage is the bottleneck |
| Not checking `systemctl --failed` after a reboot | It's the fastest way to spot broken services |

---

## 12. Quick Revision

### Key commands to memorise

```bash
# Paths & files
pwd ; ls -li ; cat -n file ; cat -E file ; tail -f /var/log/syslog
touch f ; echo "x" > f ; echo "y" >> f

# Links
ln target link          # hard link
ln -s /abs/path link    # symbolic link
find / -xtype l         # find broken symlinks

# Privilege escalation
sudo -l ; sudo -i ; sudo -s ; sudo su - ; visudo

# Users & groups
id user ; adduser user ; usermod -aG sudo user ; getent passwd user
userdel -r user ; gpasswd -d user group ; getent group group

# SSH
ssh-keygen -t ed25519 -C "you@host" ; ssh-copy-id user@host
chmod 700 ~/.ssh ; chmod 600 ~/.ssh/authorized_keys ; chmod 600 private.pem
sshd -t ; journalctl -u ssh ; ssh -v user@host

# Processes
top                       # P = CPU, M = memory, 1 = per-CPU, k = kill
ps aux --sort=-%cpu | head
kill -1 PID   # SIGHUP  → reload config
kill -15 PID  # SIGTERM → graceful stop (default)
kill -9 PID   # SIGKILL → forced (last resort)

# Memory
free -h ; swapon --show ; vmstat 1 ; sysctl vm.swappiness
dmesg -T | grep -i oom

# Packages
apt update ; apt install pkg ; apt list -a pkg ; apt-cache policy pkg
apt-mark hold pkg ; apt-mark unhold pkg
apt remove pkg ; apt purge pkg ; apt autoremove
dnf install pkg ; dnf versionlock add pkg      # RHEL family

# systemd
systemctl list-unit-files --type=service
systemctl status nginx ; systemctl enable --now nginx
systemctl reload nginx ; systemctl --failed
journalctl -u nginx -n 100 -f
systemctl daemon-reload ; systemctl cat myapp ; systemctl show myapp
```

### Key points to remember
1. `su -` = login shell (clean environment, correct PATH, home directory). `su` = non-login shell (your environment, your cwd). `sudo` prefix means you authenticate as yourself.
2. Hard link = same inode. Soft link = a path pointer. Soft links can cross filesystems and point to directories; hard links cannot.
3. `usermod -aG` appends; `usermod -G` replaces. **Always use `-aG`.**
4. `getent` sees local *and* directory (AD/LDAP/SSSD) accounts. `/etc/passwd` sees only local.
5. SSH key permissions: `700` on `~/.ssh`, `600` on `authorized_keys` and the private key. Test with `sshd -t` before reloading.
6. `top` CPU fields: `us` user, `sy` kernel, `wa` iowait, `st` steal. High `wa` = disk. High `st` = noisy cloud neighbour.
7. `SIGHUP (1)` = reload config without dropping connections. `SIGTERM (15)` = graceful stop. `SIGKILL (9)` = forced, unclean.
8. Swap is disk overflow for RAM. Tune `vm.swappiness` to 10 on servers. Disable on K8s nodes and databases. Watch for the OOM killer.
9. `apt update` refreshes the index; `apt upgrade` installs. `remove` keeps config; `purge` deletes it. `apt-mark hold` freezes a version.
10. `enabled` ≠ `active`. Always `systemctl daemon-reload` after editing a unit file. `systemctl --failed` is the fastest post-boot health check.

### Top interview questions

**Q1. Difference between `su` and `sudo su -`?**
`su` asks for the target user's password and gives a non-login shell (your environment, your cwd, possibly a wrong PATH). `sudo su -` asks for *your* password, then opens a **login shell** as root with root's full environment and home directory. `sudo -i` is the modern equivalent of `sudo su -`.

**Q2. Hard link vs soft link?**
Hard link shares the same inode and data; only works within one filesystem; can't link directories; data survives until the last link is removed. Soft link is a separate inode holding a path string; can cross filesystems and link directories; breaks if the target moves or is deleted.

**Q3. How does SSH key authentication work?**
The client holds a private key, the server holds the matching public key in `~/.ssh/authorized_keys`. The server issues a challenge; the client signs it with the private key; the server verifies with the public key. The private key never leaves the client.

**Q4. A service is not starting. What do you check?**
`systemctl status <svc>` → `journalctl -u <svc> -n 100` → `systemctl cat <svc>` (overrides) → config syntax check → port conflict (`ss -tlnp`) → file permissions and SELinux → `systemctl daemon-reload` if the unit was edited.

**Q5. Server is slow. Walk me through your approach.**
`top`/`uptime` for load average vs core count → identify whether it's CPU (`us`), kernel (`sy`), or I/O (`wa`) → `ps aux --sort=-%cpu` and `--sort=-%mem` → `vmstat 1` for swap activity → `iostat -xz 1` for disk saturation → check logs and recent changes → scale or fix.

**Q6. What is the difference between `SIGTERM`, `SIGKILL`, and `SIGHUP`?**
`SIGTERM (15)` asks the process to shut down gracefully — it can catch it, clean up, and exit. `SIGKILL (9)` cannot be caught or ignored; the kernel terminates the process immediately with no cleanup. `SIGHUP (1)` traditionally means "terminal closed" and is used by daemons like Nginx and sshd to **reload configuration without restarting**.

**Q7. Why is `usermod -aG` preferred over `usermod -G`?**
`-G` replaces the user's entire supplementary group list, silently removing them from every other group (including `sudo`). `-aG` appends the new group while preserving existing memberships.

**Q8. How do you give a user sudo access?**
`sudo usermod -aG sudo <user>` on Ubuntu (`wheel` on RHEL), then have the user re-login. For finer control, add a rule to `/etc/sudoers.d/` via `visudo -f`.

**Q9. What is swap and when is it a problem?**
Swap is disk-backed overflow for RAM. It prevents immediate OOM crashes but is orders of magnitude slower. Sustained `si`/`so` in `vmstat` means your working set exceeds RAM — add memory, reduce the app's footprint, or set container limits. In Kubernetes, swap is normally disabled.

**Q10. `apt remove` vs `apt purge`?**
Both remove the binaries. `remove` leaves configuration files behind (so a reinstall keeps your settings); `purge` deletes configuration too. Follow either with `apt autoremove` to clean unused dependencies.

**Q11. What does `systemctl enable` do, and how is it different from `start`?**
`enable` creates the symlinks so the unit starts at boot. `start` runs it now. They are independent — a service can be running but not enabled (it won't come back after reboot), or enabled but stopped.

**Q12. How would you set up passwordless SSH for a new user?**
Create the user (`adduser linuxuser`), add to sudo if needed (`usermod -aG sudo`), then as that user create `~/.ssh` with `700`, put the public key in `~/.ssh/authorized_keys` with `600`. Then verify with `ssh -i privatekey linuxuser@server`. On the server, harden `sshd_config` (`PasswordAuthentication no`, `PermitRootLogin no`), test with `sshd -t`, and reload.

**Q13. Where do you look to find out why a user cannot log in over SSH?**
Server side: `journalctl -u ssh -n 100` and `/var/log/auth.log` (Ubuntu) or `/var/log/secure` (RHEL). Client side: `ssh -vvv user@host`. Check permissions on `~/.ssh` and `authorized_keys`, check `AllowUsers`/`DenyUsers` in `sshd_config`, and check whether the account is locked (`passwd -S user`).

**Q14. What is SSSD and why does it exist?**
SSSD (System Security Services Daemon) lets a Linux host authenticate users against a central directory (AD, LDAP, Kerberos) and cache credentials for offline login. It's configured in `/etc/sssd/sssd.conf`, and `getent`/`id` resolve domain users through it. It's how enterprises avoid managing local accounts on every server.

**Q15. What does high `%st` (steal) mean in `top`?**
The hypervisor gave CPU time to another VM instead of yours. Common on oversubscribed cloud hosts. If it's sustained, move to a larger instance or a different host.
