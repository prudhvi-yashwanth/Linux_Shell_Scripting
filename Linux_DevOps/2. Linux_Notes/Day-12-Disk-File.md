# Linux - Day 12: Memory, Disks, Filesystems, and Mounts

## Overview

Today we learned how to troubleshoot:

- Out Of Memory (OOM) issues
- Memory and swap usage
- Disks and partitions
- Mounted filesystems
- Disk space vs inode usage
- `/etc/fstab`
- Mounting and unmounting filesystems
- UUIDs and persistent mounts

These commands are very useful for storage and memory troubleshooting in production.

---

# 1. Check for Out Of Memory (OOM) Errors

When Linux runs out of available memory, the **OOM Killer** can terminate processes to protect the system.

Check kernel messages using:

```bash
dmesg | grep -i "out of memory"
```

or:

```bash
journalctl -k | grep -i "oom"
```

> **Correction:** The command is `dmesg`, not `dmsg`.

---

# 2. What is `dmesg`?

`dmesg` stands for **diagnostic messages**.

It displays messages from the Linux kernel's message buffer.

Example:

```bash
dmesg
```

You can filter the output:

```bash
dmesg | grep -i "out of memory"
```

This is useful for checking:

- OOM events
- Hardware-related messages
- Driver issues
- Kernel warnings
- Boot-related information

> **Note:** On some systems, access to `dmesg` is restricted for normal users. You may need:
>
> ```bash
> sudo dmesg
> ```

---

# 3. Check Memory Usage

```bash
free -h
```

The `-h` option displays memory values in human-readable units such as:

```text
MiB
GiB
```

Example:

```text
               total        used        free      shared  buff/cache   available
Mem:            7.7Gi       3.2Gi       1.1Gi       200Mi       3.4Gi       4.0Gi
Swap:           2.0Gi       100Mi       1.9Gi
```

Important values include:

- `total` → Total RAM
- `used` → Memory currently used
- `free` → Completely unused memory
- `buff/cache` → Memory used for buffers and filesystem cache
- `available` → Approximate memory available for new applications
- `Swap` → Disk-backed memory

> **Important:** `available` is generally more useful than `free` when checking whether the system has enough memory for new workloads.

---

# 4. Check Block Devices Using `lsblk`

```bash
lsblk
```

`lsblk` stands for **list block devices**.

It displays:

- Disks
- Partitions
- Logical volumes
- Mount points

in a tree-like structure.

Example:

```text
NAME    MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda       8:0    0   20G  0 disk
├─sda1    8:1    0   19G  0 part /
├─sda13   8:13   0  923M  0 part /boot
└─sda15   8:15   0   99M  0 part /boot/efi
vda     253:0    0   54K  1 disk
```

---

# Understanding `lsblk` Output

| Column | Meaning |
|--------|---------|
| `NAME` | Device or partition name |
| `MAJ:MIN` | Major and minor device numbers |
| `RM` | Whether the device is removable |
| `SIZE` | Device size |
| `RO` | Read-only status |
| `TYPE` | Device type such as disk or partition |
| `MOUNTPOINTS` | Filesystem mount locations |

From the example:

```text
sda
├── sda1  → /
├── sda13 → /boot
└── sda15 → /boot/efi
```

This means the `sda` disk contains multiple partitions.

---

# 5. Check Filesystem Disk Usage

```bash
df -h
```

`df` stands for **disk free**.

It shows disk space usage for mounted filesystems.

The `-h` option means:

```text
Human-readable
```

so sizes are displayed as:

```text
GB
MB
GiB
MiB
```

instead of raw blocks.

Example:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        19G   10G    8G  56% /
```

---

# 6. Check Filesystem Type and Inodes

```bash
df -hT
```

Options:

- `-h` → Human-readable sizes
- `-T` → Show filesystem type

Example:

```text
Filesystem     Type  Size  Used Avail Use% Mounted on
/dev/sda1      ext4   19G   10G    8G  56% /
```

---

## Check Inode Usage

```bash
df -hi
```

Options:

- `-h` → Human-readable
- `-i` → Show inode usage instead of filesystem space usage

You can combine both filesystem type and inode information:

```bash
df -hTi
```

Options:

- `-h` → Human-readable
- `-T` → Filesystem type
- `-i` → Inode usage

---

# 7. Disk Space vs Inode Space

A very common Linux troubleshooting issue is:

```text
No space left on device
```

but:

```bash
df -h
```

shows plenty of free disk space.

This can happen when the filesystem has **run out of inodes**.

---

# What is an Inode?

An **inode** stores filesystem metadata about a file, such as:

- File type
- Permissions
- Owner
- File size
- Timestamps
- Pointers to the file's data blocks

A filesystem has a finite number of inodes.

Every file and directory consumes an inode.

---

# Real-Time Scenario

Suppose:

```bash
df -h
```

shows:

```text
Use% = 40%
```

but creating a file gives:

```text
No space left on device
```

Check:

```bash
df -hi
```

You may find:

```text
IUse% = 100%
```

This means the filesystem has run out of inodes.

A common cause is millions of small files, such as:

- Session files
- Cache files
- Temporary files
- Application-generated files

---

# Finding Large Numbers of Files

One possible investigation is:

```bash
find /path -xdev -type f | wc -l
```

This counts files under the specified path.

> **Note:** Be careful when running `find` on large production filesystems because scanning millions of files can itself consume CPU and I/O.

---

# 8. View Mounted Filesystems

```bash
mount
```

Displays currently mounted filesystems.

For a more readable output:

```bash
mount | column -t
```

The `column -t` command formats the output into aligned columns.

---

# 9. What is Mounting?

Mounting means making a filesystem available at a directory called a **mount point**.

Example:

```text
Disk /dev/sdb1
      │
      ▼
Mounted at /data
```

After mounting:

```text
/data
```

can be used to access the filesystem.

---

# 10. `/etc/fstab`

```bash
cat /etc/fstab
```

The `/etc/fstab` file contains filesystem mount information that Linux uses for **automatic mounting**, typically during boot.

A typical entry contains:

```text
device
mount point
filesystem type
options
dump
pass
```

---

# `/etc/fstab` Fields

Each entry generally follows:

```text
device  mount_point  filesystem_type  options  dump  pass
```

Example:

```text
UUID=xxxx-xxxx  /data  ext4  defaults  0  2
```

### Fields

| Field | Meaning |
|-------|---------|
| `device` | Device, UUID, or label identifying the filesystem |
| `mount_point` | Directory where the filesystem should be mounted |
| `filesystem_type` | Filesystem type such as `ext4` or `xfs` |
| `options` | Mount options such as `defaults`, `ro`, or `nofail` |
| `dump` | Legacy dump utility setting; commonly `0` |
| `pass` | Filesystem check order for `fsck` during boot |

---

# 11. Create a Mount Point

Create a directory where the filesystem will be mounted:

```bash
sudo mkdir -p /mnt/testdisk
```

The `-p` option creates the directory and any missing parent directories.

---

# 12. Mount a Filesystem

If you have a spare partition, for example:

```text
/dev/sdb1
```

you can mount it using:

```bash
sudo mount /dev/sdb1 /mnt/testdisk
```

After mounting, verify:

```bash
df -h
```

or:

```bash
lsblk
```

> **Important:** Do not run `mount` against a production partition unless you know exactly which device and filesystem you are working with. Mounting or formatting the wrong device can cause data loss.

---

# 13. Unmount a Filesystem

```bash
sudo umount /mnt/testdisk
```

> **Important:** The command is `umount`, not `unmount`.

You can also unmount using the device:

```bash
sudo umount /dev/sdb1
```

---

# 14. Persistent Mounts

A filesystem mounted manually using:

```bash
sudo mount /dev/sdb1 /mnt/testdisk
```

may not automatically be mounted after a reboot.

To make the mount persistent, add an entry to:

```text
/etc/fstab
```

Example:

```text
UUID=xxxx-xxxx  /mnt/testdisk  ext4  defaults  0  2
```

Then test the configuration before rebooting:

```bash
sudo mount -a
```

If there are no errors, verify:

```bash
df -h
```

> **Best Practice:** Always run `sudo mount -a` to validate a new `/etc/fstab` entry before rebooting. A broken `fstab` entry can cause boot problems.

---

# 15. Why UUID is Important

A device name such as:

```text
/dev/sdb1
```

can potentially change between boots or when hardware/storage configuration changes.

A filesystem UUID is a stable identifier for the filesystem.

Example:

```text
UUID=7f3c8e2a-1234-4567-89ab-123456789abc
```

You can view filesystem UUIDs using:

```bash
lsblk -f
```

or:

```bash
sudo blkid
```

---

# Example: Using UUID in `/etc/fstab`

Suppose:

```bash
lsblk -f
```

shows:

```text
NAME   FSTYPE UUID                                 MOUNTPOINTS
sdb1   ext4   7f3c8e2a-1234-4567-89ab-123456789abc
```

Create a mount point:

```bash
sudo mkdir -p /data
```

Add to `/etc/fstab`:

```text
UUID=7f3c8e2a-1234-4567-89ab-123456789abc  /data  ext4  defaults  0  2
```

Test:

```bash
sudo mount -a
```

Verify:

```bash
df -h /data
```

---

# 16. Real-Time Production Scenario

Suppose a server has a separate data volume:

```text
/dev/sdb1 → /data
```

The administrator manually mounts it:

```bash
sudo mount /dev/sdb1 /data
```

Everything works.

Later, the server is rebooted.

After the reboot:

```text
/data
```

is no longer mounted.

Applications that depend on `/data` start failing.

### Why?

The filesystem was manually mounted but was not configured in:

```text
/etc/fstab
```

Therefore, Linux did not know that it needed to mount the volume automatically during boot.

---

# Production Fix

Find the UUID:

```bash
lsblk -f
```

Add the filesystem to `/etc/fstab`:

```text
UUID=<filesystem-uuid>  /data  ext4  defaults  0  2
```

Test:

```bash
sudo mount -a
```

Verify:

```bash
df -h /data
```

Now the filesystem can be mounted automatically during boot.

---

# Storage Troubleshooting Flow

```text
Application Cannot Write
        │
        ▼
Check Disk Space
        │
        ▼
df -h
        │
        ├── Disk Full
        │      │
        │      ▼
        │   Find Large Files
        │
        └── Disk Has Space
               │
               ▼
             df -hi
               │
               ├── Inodes Full
               │      │
               │      ▼
               │   Find Many Small Files
               │
               └── Inodes Available
                      │
                      ▼
                Check Mounts
                      │
                      ▼
                 lsblk / mount
                      │
                      ▼
              Check /etc/fstab
```

---

# Useful Commands

```bash
# Check kernel messages
dmesg | grep -i "out of memory"

# Check kernel OOM events through systemd journal
journalctl -k | grep -i "oom"

# Check memory and swap
free -h

# List disks and partitions
lsblk

# List disks with filesystem information
lsblk -f

# Check mounted filesystem disk usage
df -h

# Check filesystem type
df -hT

# Check inode usage
df -hi

# Check filesystem type and inode usage
df -hTi

# Show mounted filesystems
mount

# Show mounted filesystems in aligned columns
mount | column -t

# View persistent mount configuration
cat /etc/fstab

# Create a mount point
sudo mkdir -p /mnt/testdisk

# Mount a filesystem
sudo mount /dev/sdb1 /mnt/testdisk

# Unmount a filesystem
sudo umount /mnt/testdisk

# Find filesystem UUID
sudo blkid

# Validate and mount filesystems from /etc/fstab
sudo mount -a
```

---

# Quick Revision

```text
dmesg
→ View Linux kernel diagnostic messages

journalctl -k
→ View kernel messages from the systemd journal

free -h
→ Check RAM and swap

lsblk
→ View disks and partitions

lsblk -f
→ View disks, filesystems, UUIDs, and mount points

df -h
→ Check disk space on mounted filesystems

df -hT
→ Check disk space + filesystem type

df -hi
→ Check inode usage

mount
→ View currently mounted filesystems

/etc/fstab
→ Defines persistent filesystem mounts

UUID
→ Stable identifier for a filesystem

mount
→ Attach a filesystem to a mount point

umount
→ Detach a filesystem
```

---

# Important Production Lessons

1. **Disk space and inode space are different.**
2. A filesystem can have free disk space but still fail with `No space left on device` because all inodes are used.
3. Always check `df -h` and `df -hi` when troubleshooting storage issues.
4. Use `lsblk -f` or `blkid` to identify filesystem UUIDs.
5. Use UUIDs in `/etc/fstab` for more reliable persistent mounts.
6. Always test `/etc/fstab` changes with:

```bash
sudo mount -a
```

before rebooting.
7. Be very careful when mounting, unmounting, or modifying storage on production systems.

