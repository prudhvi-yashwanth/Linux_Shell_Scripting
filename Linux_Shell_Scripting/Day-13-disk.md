# Linux - Day 13: Disk Troubleshooting

## Overview

Today we learned how to troubleshoot disk-related issues in Linux.

The main topics are:

- `df`
- `du`
- `lsblk`
- `ncdu`
- Disk mounting
- Filesystem formatting
- UUID
- `/etc/fstab`
- Safe testing of persistent mounts

---

# 1. `df` vs `du`

Two important commands for disk troubleshooting are:

```bash
df
```

and:

```bash
du
```

They serve different purposes.

| Command | Purpose |
|---------|---------|
| `df -h` | Shows filesystem-level disk usage |
| `du -sh` | Shows how much space files/directories are using |

---

# 2. `df -h`

```bash
df -h
```

Shows the available and used space of mounted filesystems.

The `-h` option means **human-readable**.

Example:

```text
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1        20G   10G   10G  50% /
```

---

# 3. `No Space Left on Device` Even When `df -h` Shows Free Space

Sometimes you may see:

```text
No space left on device
```

even though:

```bash
df -h
```

shows plenty of free disk space.

A common reason is **inode exhaustion**.

Check inode usage:

```bash
df -hi
```

If the inode usage is:

```text
IUse% = 100%
```

the filesystem has run out of inodes, even though there may still be free space in bytes.

This commonly happens when there are millions of small files, such as:

- Cache files
- Session files
- Temporary files
- Application-generated files

---

# 4. `lsblk`

```bash
lsblk
```

`lsblk` stands for **list block devices**.

It shows disks and partitions in a tree structure.

Example:

```text
sda
├─sda1
├─sda13
└─sda15
```

This helps identify:

- Disks
- Partitions
- Logical volumes
- Mount points

---

# 5. `du`

The `du` command shows how much disk space files and directories are using.

### Basic Syntax

```bash
du [options] [path]
```

---

# 6. `du -sh`

```bash
du -sh /var
```

Options:

- `-s` → Summary; show one total for the specified path.
- `-h` → Human-readable sizes.

Example:

```text
5.2G    /var
```

---

# 7. Find the Largest Directories

A useful disk-troubleshooting command is:

```bash
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

This helps identify which directories are consuming the most space.

---

# Command Breakdown

## `du -sh`

```bash
du -sh
```

- `-s` → Summary
- `-h` → Human-readable

---

## `/var/*`

```bash
/var/*
```

Checks each top-level item inside `/var`.

For example:

```text
/var/log
/var/cache
/var/lib
/var/tmp
```

---

## `2>/dev/null`

```bash
2>/dev/null
```

Redirects error messages to `/dev/null`.

This hides errors such as:

```text
Permission denied
```

---

## `sort -rh`

```bash
sort -rh
```

Options:

- `-r` → Reverse order
- `-h` → Understand human-readable sizes such as `G`, `M`, and `K`

This puts the largest directories at the top.

---

## `head -10`

```bash
head -10
```

Displays only the top 10 results.

---

# Complete Flow

```text
du -sh /var/*
       │
       ▼
Find directory sizes
       │
       ▼
sort -rh
       │
       ▼
Largest directories first
       │
       ▼
head -10
       │
       ▼
Show top 10
```

---

# 8. Drill Deeper into a Directory

Once you identify a large directory, investigate inside it.

For example:

```bash
du -sh /var/log/* 2>/dev/null | sort -rh | head -10
```

This helps identify which files or subdirectories inside `/var/log` are consuming the most space.

Example:

```text
40G     /var/log/application.log
12G     /var/log/journal
2G      /var/log/nginx
```

Now you know where to investigate.

---

# Real-Time Production Scenario

Suppose a disk alert fires at 2 AM:

```text
Disk Usage: 95%
```

Instead of checking every directory manually:

### Step 1

```bash
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

You may find:

```text
50G /var/log
20G /var/lib
5G  /var/cache
```

### Step 2

Drill into `/var/log`:

```bash
du -sh /var/log/* 2>/dev/null | sort -rh | head -10
```

You may find:

```text
40G /var/log/application.log
5G  /var/log/journal
```

Now you know exactly what is consuming the disk space.

This is much faster than checking directories randomly.

> **Important:** Do not delete production logs blindly. First understand whether the application or logging system is misconfigured, and check the organisation's log-retention and rotation policy.

---

# 9. `ncdu`

`ncdu` stands for:

**NCurses Disk Usage**

Install it on Ubuntu:

```bash
sudo apt update
sudo apt install -y ncdu
```

Run:

```bash
ncdu /
```

or:

```bash
ncdu /var
```

It provides an interactive view of disk usage.

You can:

- Navigate through directories
- Identify large files
- Drill down into directories
- Inspect disk usage interactively

Navigation is usually done using the keyboard.

> **Important:** `ncdu` also provides file deletion options. Be very careful when using them on production systems.

---

# 10. Mounting a New Disk

When adding a new disk to a Linux server, the general process is:

```text
New Disk
   │
   ▼
Partition the disk
   │
   ▼
Create a filesystem
   │
   ▼
Create a mount point
   │
   ▼
Mount the filesystem
   │
   ▼
Find UUID
   │
   ▼
Add /etc/fstab entry
   │
   ▼
Run mount -a
   │
   ▼
Verify mount
```

> **Important:** Partitioning and formatting can destroy existing data. Never run these commands on a disk until you have confirmed that it is the correct device.

---

# 11. Partition the Disk

If the disk is completely new and does not have a partition, create a partition first.

You can inspect available disks using:

```bash
lsblk
```

For partitioning, tools such as:

```bash
fdisk
```

or:

```bash
parted
```

can be used.

Example:

```bash
sudo fdisk /dev/sdb
```

> Only partition a disk after confirming that `/dev/sdb` is the correct disk.

---

# 12. Create a Filesystem

After creating a partition, create a filesystem.

For example, using `ext4`:

```bash
sudo mkfs.ext4 /dev/sdb1
```

You can also use other filesystems such as:

```text
ext4
xfs
```

depending on the operating system and workload requirements.

> **Warning:** `mkfs` formats the target device and can permanently destroy existing data.

---

# 13. Create a Mount Point

Create a directory where the filesystem will be mounted:

```bash
sudo mkdir -p /mnt/testdisk
```

---

# 14. Mount the Filesystem

```bash
sudo mount /dev/sdb1 /mnt/testdisk
```

Verify:

```bash
df -h
```

or:

```bash
lsblk -f
```

---

# 15. Get the UUID

A filesystem has a UUID that uniquely identifies it.

Use:

```bash
lsblk -f
```

or:

```bash
sudo blkid
```

Example:

```text
/dev/sdb1: UUID="7f3c8e2a-1234-4567-89ab-123456789abc" TYPE="ext4"
```

---

# Why Use UUID?

Device names such as:

```text
/dev/sdb1
```

can change depending on the system and storage configuration.

Using the UUID in `/etc/fstab` provides a more reliable way to identify the filesystem.

---

# 16. Backup `/etc/fstab`

Before modifying `/etc/fstab`, create a backup.

```bash
sudo cp /etc/fstab /etc/fstab.backup
```

Then inspect the current file:

```bash
cat /etc/fstab
```

---

# 17. `/etc/fstab` Fields

Each entry generally follows:

```text
device  mount_point  filesystem_type  options  dump  pass
```

Example:

```text
UUID=7f3c8e2a-1234-4567-89ab-123456789abc  /mnt/testdisk  ext4  defaults  0  2
```

### Fields

| Field | Meaning |
|-------|---------|
| `device` | Device, UUID, or filesystem label |
| `mount_point` | Directory where the filesystem should be mounted |
| `filesystem_type` | Filesystem type such as `ext4` |
| `options` | Mount options such as `defaults` |
| `dump` | Legacy dump utility setting, commonly `0` |
| `pass` | Filesystem check order during boot |

---

# 18. Add the New Filesystem to `/etc/fstab`

Example:

```text
UUID=your-uuid-here  /mnt/testdisk  ext4  defaults  0  2
```

Replace:

```text
your-uuid-here
```

with the actual UUID from:

```bash
lsblk -f
```

or:

```bash
sudo blkid
```

---

# 19. Test `/etc/fstab` Without Rebooting

This is one of the most important production safety steps.

Run:

```bash
sudo mount -a
```

This tells Linux to mount the filesystems defined in `/etc/fstab` that are not already mounted.

If the configuration is invalid, you should get an error immediately.

Then verify:

```bash
df -h | grep testdisk
```

or:

```bash
mount | grep testdisk
```

---

# Why `mount -a` Is Important

Suppose you add:

```text
UUID=wrong-uuid  /mnt/testdisk  ext4  defaults  0  2
```

and reboot immediately.

The mount may fail during boot.

Instead:

```bash
sudo mount -a
```

checks the configuration before you reboot.

Recommended flow:

```text
Backup /etc/fstab
       │
       ▼
Edit /etc/fstab
       │
       ▼
sudo mount -a
       │
       ▼
Any error?
   │       │
  Yes      No
   │        │
   ▼        ▼
Fix it    Verify mount
             │
             ▼
          Reboot later
```

---

# Real-Time Production Scenario

Suppose a server receives a new data volume:

```text
/dev/sdb1
```

You mount it:

```bash
sudo mount /dev/sdb1 /data
```

The application works correctly.

After a server reboot:

```text
/data is missing
```

The application fails because the data volume was not mounted automatically.

### Root Cause

The disk was manually mounted, but the filesystem was not added to:

```text
/etc/fstab
```

### Correct Solution

Find the UUID:

```bash
lsblk -f
```

Add it to `/etc/fstab`:

```text
UUID=<actual-uuid>  /data  ext4  defaults  0  2
```

Test:

```bash
sudo mount -a
```

Verify:

```bash
df -h /data
```

Now the filesystem is configured for persistent mounting.

---

# Complete Disk Troubleshooting Flow

```text
Disk Alert
    │
    ▼
df -h
    │
    ├── Disk Space Full
    │       │
    │       ▼
    │     du -sh
    │       │
    │       ▼
    │   Find Heavy Directory
    │       │
    │       ▼
    │   Drill Deeper
    │
    └── Disk Space Available
            │
            ▼
          df -hi
            │
            ├── Inodes Full
            │       │
            │       ▼
            │   Find Many Small Files
            │
            └── Inodes Available
                    │
                    ▼
                Check Mounts
                    │
                    ▼
                 lsblk -f
                    │
                    ▼
               Check /etc/fstab
```

---

# Useful Commands

```bash
# Check filesystem disk usage
df -h

# Check inode usage
df -hi

# List disks and partitions
lsblk

# List disks with filesystem information and UUID
lsblk -f

# Find large directories
du -sh /var/* 2>/dev/null | sort -rh | head -10

# Drill into a specific directory
du -sh /var/log/* 2>/dev/null | sort -rh | head -10

# Interactive disk usage
ncdu /var

# Display mounted filesystems
mount

# Display fstab configuration
cat /etc/fstab

# Backup fstab
sudo cp /etc/fstab /etc/fstab.backup

# Get filesystem UUID
sudo blkid

# Create mount point
sudo mkdir -p /mnt/testdisk

# Mount filesystem
sudo mount /dev/sdb1 /mnt/testdisk

# Validate fstab entries
sudo mount -a

# Verify mount
df -h | grep testdisk
```

---

# Quick Revision

```text
df -h
→ Shows filesystem disk usage

df -hi
→ Shows inode usage

lsblk
→ Shows disks and partitions

lsblk -f
→ Shows filesystem type, UUID, and mount points

du -sh
→ Shows directory/file disk usage

ncdu
→ Interactive disk usage viewer

mount
→ Shows currently mounted filesystems

/etc/fstab
→ Defines persistent filesystem mounts

UUID
→ Stable filesystem identifier

mount -a
→ Tests and mounts filesystems configured in /etc/fstab
```

---

# Important Production Lessons

1. `df -h` and `du` answer different questions.
2. `df -h` shows filesystem usage, while `du` helps identify which files and directories consume the space.
3. If `df -h` shows free space but you still get `No space left on device`, check:

```bash
df -hi
```

4. Always confirm the correct disk before partitioning or formatting.
5. Use UUIDs for persistent filesystem entries in `/etc/fstab`.
6. Back up `/etc/fstab` before editing it.
7. Always run:

```bash
sudo mount -a
```

after editing `/etc/fstab` and before rebooting.
8. Never blindly delete large files on production servers. Check log rotation, retention policies, application behaviour, and whether the files are safe to remove.

---
