# Linux - Disk Troubleshooting Q&A

## Question 2

### Question

**A production volume managed by LVM is nearly full and cannot be taken offline. Write the two-command sequence to grow it live.**

### Answer

For an `ext4` filesystem:

```bash
sudo lvextend -L +<size> /dev/<vg-name>/<lv-name>
sudo resize2fs /dev/<vg-name>/<lv-name>
```

Example:

```bash
sudo lvextend -L +20G /dev/data-vg/data-lv
sudo resize2fs /dev/data-vg/data-lv
```

### Explanation

```text
Logical Volume
      │
      ▼
lvextend
      │
      ▼
LV becomes larger
      │
      ▼
resize2fs
      │
      ▼
Filesystem becomes larger
      │
      ▼
df -h shows new space
```

> **Important:** `resize2fs` is for `ext4`. If the filesystem is XFS, use:
>
> ```bash
> sudo xfs_growfs /mount-point
> ```

---

# Question 11

### Question

**After running `lvextend`, why is a second command required before `df -h` reflects the new size?**

### Answer

`lvextend` increases the size of the **Logical Volume**, but the filesystem inside that Logical Volume does not automatically grow in every workflow.

For `ext4`:

```bash
sudo resize2fs /dev/<vg-name>/<lv-name>
```

is used to expand the filesystem and make use of the additional space.

The process is:

```text
Before:

LV = 10 GB
Filesystem = 10 GB


After lvextend:

LV = 20 GB
Filesystem = 10 GB


After resize2fs:

LV = 20 GB
Filesystem = 20 GB
```

Then:

```bash
df -h
```

will show the increased filesystem size.

> **Common mistake:** Running `lvextend` and then checking `df -h` without growing the filesystem. The LV has become larger, but the filesystem may still report its old size.

---

# Question 12

### Question

**When a production disk-full alert fires, what do you check first, second, and third? Explain the order and why.**

## Correct Troubleshooting Order

### 1. Check Filesystem Space

```bash
df -h
```

### Why first?

It is fast and tells you whether the problem is actually **disk-space exhaustion**.

Example:

```text
Filesystem      Size  Used Avail Use%
/dev/sda1        50G   49G   1G   98%
```

This confirms that the filesystem is almost full.

---

# 2. Check Inode Usage

```bash
df -i
```

### Why second?

A filesystem can have free disk space but still fail with:

```text
No space left on device
```

because it has run out of **inodes**.

Example:

```text
Filesystem      Inodes  IUsed  IFree IUse%
/dev/sda1       3.2M    3.2M      0  100%
```

This means the filesystem has no free inodes left.

This commonly happens when there are millions of small files.

---

# 3. Find What Is Consuming the Space

Once `df -h` confirms that disk space is the problem, use `du` to find the directories consuming the most space.

Example:

```bash
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

### Why third?

`du` recursively calculates the space used by files and directories.

This helps narrow the problem from:

```text
Disk is full
```

to:

```text
/var/log is using 40 GB
```

and then further:

```bash
du -sh /var/log/* 2>/dev/null | sort -rh | head -10
```

---

# Complete Disk Troubleshooting Flow

```text
Disk-Full Alert
      │
      ▼
1. df -h
      │
      ├── Disk space full
      │       │
      │       ▼
      │     Continue
      │
      └── Disk space available
              │
              ▼
         Check inodes
              │
              ▼
2. df -i
      │
      ├── Inodes full
      │       │
      │       ▼
      │   Find excessive small files
      │
      └── Inodes available
              │
              ▼
3. du -sh ...
      │
      ▼
Find largest directories/files
```

---

# `find` vs `du`

A common mistake is using:

```bash
find /var -type d -size +500M
```

to find large directories.

This does **not** measure the total size of all files inside each directory.

The `-size` test on a directory measures the directory's own filesystem entry size, not the cumulative size of its contents.

For example:

```text
/var/log
   ├── app.log      10 GB
   ├── nginx.log     5 GB
   └── system.log    2 GB
```

The directory itself may still have a relatively small directory-entry size.

Therefore:

```text
find -size
→ Best for finding individual files by size

du
→ Best for measuring total directory usage
```

### Rule to Remember

```text
Find a large FILE
    → find

Measure a large DIRECTORY
    → du
```

---

# Quick Revision

```bash
# 1. Check filesystem space
df -h

# 2. Check inode usage
df -i

# 3. Find largest directories
du -sh /var/* 2>/dev/null | sort -rh | head -10
```

### LVM Expansion

```bash
# Extend Logical Volume
sudo lvextend -L +20G /dev/data-vg/data-lv

# Grow ext4 filesystem
sudo resize2fs /dev/data-vg/data-lv
```

For XFS:

```bash
sudo xfs_growfs /data
```

### Key Concept

```text
lvextend
→ Increases the Logical Volume

resize2fs / xfs_growfs
→ Increases the filesystem

df -h
→ Shows the filesystem's usable size
```
