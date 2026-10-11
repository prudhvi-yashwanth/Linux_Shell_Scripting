# Linux - Day 14: LVM Basics

## Overview

**LVM (Logical Volume Manager)** provides a flexible way to manage disk storage in Linux.

Regular disk partitions are often difficult to resize because their size is fixed. LVM adds an abstraction layer that allows logical volumes to be extended more easily.

A common production use case is:

```text
Disk almost full
      │
      ▼
Add storage
      │
      ▼
Extend LVM
      │
      ▼
Extend filesystem
      │
      ▼
More space available
```

For supported filesystems and workloads, a logical volume and its filesystem can often be extended **online**, without unmounting the filesystem or rebooting the server.

> **Important:** Extending storage is not automatically zero-downtime in every situation. The filesystem must support online expansion, sufficient storage must be available, and the correct commands must be used.

---

# LVM Architecture

LVM has three main layers:

```text
Physical Volume (PV)
        │
        ▼
Volume Group (VG)
        │
        ▼
Logical Volume (LV)
        │
        ▼
Filesystem
        │
        ▼
Mount Point
```

---

# 1. Physical Volume (PV)

A **Physical Volume** is a disk, disk partition, or suitable block device prepared for use by LVM.

Example:

```text
/dev/sdb1
```

After running:

```bash
sudo pvcreate /dev/sdb1
```

it becomes an LVM Physical Volume.

---

# 2. Volume Group (VG)

A **Volume Group** combines one or more Physical Volumes into a storage pool.

Example:

```text
PV1 → 100 GB
PV2 → 100 GB
PV3 → 200 GB
       │
       ▼
Volume Group = 400 GB
```

Example command:

```bash
sudo vgcreate data-vg /dev/sdb1
```

---

# 3. Logical Volume (LV)

A **Logical Volume** is a flexible virtual block device created from the free space in a Volume Group.

Example:

```text
Volume Group
    │
    ├── LV1 → 100 GB
    ├── LV2 → 200 GB
    └── Free → 100 GB
```

Example:

```bash
sudo lvcreate -L 100G -n data-lv data-vg
```

The Logical Volume is what you normally format with a filesystem and mount.

---

# Why Do We Need LVM?

Without LVM:

```text
Disk Partition
     │
     ▼
Fixed-size Filesystem
```

Increasing the size can be more difficult and may require partition changes.

With LVM:

```text
Disk / Partition
      │
      ▼
Physical Volume
      │
      ▼
Volume Group
      │
      ▼
Logical Volume
      │
      ▼
Filesystem
```

The extra layer gives more flexibility.

---

# Increasing Storage Without Downtime

Suppose a production database filesystem is:

```text
/dev/data-vg/data-lv
```

and usage reaches:

```text
80%
```

The goal is to increase the available space without taking the database offline.

There are two common cases.

---

# Case 1: Volume Group Already Has Free Space

Suppose:

```text
VG Size      = 100 GB
LV Size      = 60 GB
VG Free      = 40 GB
```

You can increase the LV using the available VG space.

```text
Volume Group
┌───────────────────────────────┐
│ LV = 60 GB │ Free = 40 GB    │
└───────────────────────────────┘
```

Extend the LV:

```bash
sudo lvextend -L +20G /dev/data-vg/data-lv
```

Then extend the filesystem.

For `ext4`:

```bash
sudo resize2fs /dev/data-vg/data-lv
```

For XFS:

```bash
sudo xfs_growfs /mount-point
```

> **Important:** `resize2fs` is for `ext2/ext3/ext4`. XFS uses `xfs_growfs`.

---

# Case 2: Volume Group Has No Free Space

Suppose:

```text
VG Size      = 100 GB
LV Size      = 100 GB
VG Free      = 0 GB
```

You first need to add a new disk or partition.

Example:

```text
New Disk
/dev/sdc
    │
    ▼
PV
    │
    ▼
Add PV to Existing VG
    │
    ▼
VG has Free Space
    │
    ▼
Extend LV
    │
    ▼
Extend Filesystem
```

---

# Production Example

Suppose:

```text
Database Filesystem = 80 GB
Usage               = 80%
```

A new 50 GB disk is attached:

```text
/dev/sdc
```

We can:

```text
/dev/sdc
    │
    ▼
pvcreate
    │
    ▼
vgextend
    │
    ▼
lvextend
    │
    ▼
resize2fs / xfs_growfs
```

The database filesystem can then have more free space without a traditional filesystem unmount.

---

# LVM Practice Setup

The following example uses a **loop device backed by a file**.

This is useful for learning LVM without attaching a real disk.

> **Important:** A loop-backed LVM setup is suitable for practice. Production systems normally use real block devices, partitions, or cloud volumes.

---

# 1. Install LVM Tools

On Ubuntu:

```bash
sudo apt update
sudo apt install -y lvm2
```

This installs the LVM utilities.

---

# 2. Create a Disk Image File

```bash
sudo fallocate -l 2G /root/lvmdisk.img
```

This creates a 2 GB file that will be used as a virtual block device for practice.

---

# 3. Attach the Image as a Loop Device

```bash
sudo losetup -fP /root/lvmdisk.img
```

This attaches the image file to an available `/dev/loopX` device.

Find the assigned loop device:

```bash
losetup -a
```

Example:

```text
/dev/loop0: ... (/root/lvmdisk.img)
```

Here:

```text
/dev/loop0
```

is the device we will use.

---

# 4. Create a Physical Volume

```bash
sudo pvcreate /dev/loop0
```

This prepares the loop device for LVM.

Verify:

```bash
sudo pvs
```

or:

```bash
sudo pvdisplay
```

Example:

```text
PV         VG   Fmt  Attr PSize  PFree
/dev/loop0     lvm2      2.00g  2.00g
```

---

# 5. Create a Volume Group

Create a VG named:

```text
practice-vg
```

using the Physical Volume:

```bash
sudo vgcreate practice-vg /dev/loop0
```

Verify:

```bash
sudo vgs
```

or:

```bash
sudo vgdisplay practice-vg
```

---

# 6. Create a Logical Volume

Create a 1 GB Logical Volume:

```bash
sudo lvcreate -L 1G -n practice-lv practice-vg
```

This creates:

```text
VG: practice-vg
        │
        ▼
LV: practice-lv
Size: 1 GB
```

Verify:

```bash
sudo lvs
```

---

# 7. Create a Filesystem

Create an `ext4` filesystem:

```bash
sudo mkfs.ext4 /dev/practice-vg/practice-lv
```

> **Warning:** `mkfs` formats the Logical Volume and destroys any existing data on that LV.

---

# 8. Create a Mount Point

```bash
sudo mkdir -p /mnt/lvmtest
```

This directory will be used as the mount point.

---

# 9. Mount the Logical Volume

```bash
sudo mount /dev/practice-vg/practice-lv /mnt/lvmtest
```

---

# 10. Verify the Mount

```bash
df -h | grep lvmtest
```

Example:

```text
/dev/mapper/practice--vg-practice--lv  1.0G   ...   /mnt/lvmtest
```

You can also check:

```bash
lsblk
```

or:

```bash
findmnt /mnt/lvmtest
```

---

# Complete Practice Flow

```text
/root/lvmdisk.img
        │
        ▼
   /dev/loop0
        │
        ▼
 Physical Volume
        │
        ▼
   practice-vg
        │
        ▼
   practice-lv
        │
        ▼
      ext4
        │
        ▼
 /mnt/lvmtest
```

---

# Extending the Logical Volume

Suppose the Volume Group has enough free space.

Check:

```bash
sudo vgs
```

Example:

```text
VG           VSize  VFree
practice-vg  2.00g  1.00g
```

Now extend the LV by 500 MB:

```bash
sudo lvextend -L +500M /dev/practice-vg/practice-lv
```

Check:

```bash
sudo lvs
```

The LV size will now be approximately:

```text
1.5G
```

---

# Extend the ext4 Filesystem

After extending the LV:

```bash
sudo resize2fs /dev/practice-vg/practice-lv
```

Then verify:

```bash
df -h /mnt/lvmtest
```

---

# Easier Method: Extend LV and Filesystem Together

With supported filesystems, `lvextend` can resize the filesystem automatically using:

```bash
sudo lvextend -r -L +500M /dev/practice-vg/practice-lv
```

The `-r` option tells LVM to resize the filesystem along with the Logical Volume.

This is often simpler because it performs both operations together.

```text
LV Extend
   +
Filesystem Resize
   =
lvextend -r
```

> **Best Practice:** Understand both approaches. In production, confirm the filesystem type and verify that the filesystem supports online growth before using this.

---

# Adding a New Disk to the Volume Group

Suppose the current VG has no free space.

A new disk is attached:

```text
/dev/sdc
```

Check:

```bash
lsblk
```

---

# 1. Create a Physical Volume

```bash
sudo pvcreate /dev/sdc
```

Verify:

```bash
sudo pvs
```

---

# 2. Add the PV to the Existing VG

```bash
sudo vgextend practice-vg /dev/sdc
```

Verify:

```bash
sudo vgs
```

Now the Volume Group has additional free space.

---

# 3. Extend the Logical Volume

For example:

```bash
sudo lvextend -L +2G /dev/practice-vg/practice-lv
```

---

# 4. Extend the Filesystem

For `ext4`:

```bash
sudo resize2fs /dev/practice-vg/practice-lv
```

Or:

```bash
sudo lvextend -r -L +2G /dev/practice-vg/practice-lv
```

For XFS:

```bash
sudo xfs_growfs /mnt/lvmtest
```

---

# Complete Production Expansion Flow

```text
Filesystem Nearly Full
          │
          ▼
Check LV and VG
          │
          ▼
     VG has free space?
        │          │
       Yes         No
        │           │
        ▼           ▼
    lvextend    Add New Disk
        │           │
        │           ▼
        │       pvcreate
        │           │
        │           ▼
        │       vgextend
        │           │
        └──────┬────┘
               ▼
           lvextend
               │
               ▼
       Resize Filesystem
               │
          ┌────┴─────┐
          ▼          ▼
        ext4        XFS
          │          │
          ▼          ▼
     resize2fs   xfs_growfs
          │          │
          └────┬─────┘
               ▼
        Verify New Space
```

---

# Important Commands

## Check Physical Volumes

```bash
sudo pvs
```

More details:

```bash
sudo pvdisplay
```

---

## Check Volume Groups

```bash
sudo vgs
```

More details:

```bash
sudo vgdisplay
```

---

## Check Logical Volumes

```bash
sudo lvs
```

More details:

```bash
sudo lvdisplay
```

---

## Extend a Logical Volume

```bash
sudo lvextend -L +1G /dev/vg-name/lv-name
```

---

## Extend LV and Filesystem Together

```bash
sudo lvextend -r -L +1G /dev/vg-name/lv-name
```

---

## Extend a Volume Group

```bash
sudo vgextend <vg-name> <device>
```

Example:

```bash
sudo vgextend practice-vg /dev/sdc
```

---

## Resize an ext4 Filesystem

```bash
sudo resize2fs /dev/vg-name/lv-name
```

---

## Grow an XFS Filesystem

```bash
sudo xfs_growfs /mount-point
```

---

# Check the Entire LVM Setup

Useful commands:

```bash
lsblk
```

```bash
sudo pvs
```

```bash
sudo vgs
```

```bash
sudo lvs
```

```bash
df -h
```

These commands show the storage at different layers.

```text
lsblk → Block devices
pvs   → Physical Volumes
vgs   → Volume Groups
lvs   → Logical Volumes
df    → Filesystem usage
```

---

# Production Scenario

## Scenario 1: Database Volume is 80% Full

Suppose:

```text
Database filesystem:
80% used
```

The database cannot be stopped.

### Step 1: Check Filesystem

```bash
df -h /data
```

### Step 2: Check LVM

```bash
sudo lvs
sudo vgs
```

If VG has enough free space:

```bash
sudo lvextend -r -L +20G /dev/data-vg/data-lv
```

Verify:

```bash
df -h /data
```

This can extend the Logical Volume and supported filesystem online without an application downtime window.

---

# Scenario 2: VG Has No Free Space

Suppose:

```text
VG Free = 0
```

Attach a new disk.

Check:

```bash
lsblk
```

Suppose the new disk is:

```text
/dev/sdc
```

Create the PV:

```bash
sudo pvcreate /dev/sdc
```

Add it to the VG:

```bash
sudo vgextend data-vg /dev/sdc
```

Check:

```bash
sudo vgs
```

Then extend the LV:

```bash
sudo lvextend -r -L +20G /dev/data-vg/data-lv
```

Verify:

```bash
df -h /data
```

---

# Important Production Checks

Before extending storage:

```bash
df -h
```

Check:

```bash
sudo lvs
sudo vgs
sudo pvs
```

Confirm:

- Correct VG
- Correct LV
- Available free space
- Correct filesystem type
- Correct mount point
- Correct device path

After the change:

```bash
df -h
sudo lvs
sudo vgs
```

Confirm that the new capacity is available.

---

# LVM Troubleshooting Commands

```bash
# Check disks and partitions
lsblk

# Check filesystem usage
df -h

# Check Physical Volumes
sudo pvs

# Check Volume Groups
sudo vgs

# Check Logical Volumes
sudo lvs

# Detailed PV information
sudo pvdisplay

# Detailed VG information
sudo vgdisplay

# Detailed LV information
sudo lvdisplay

# Find filesystem type
lsblk -f
```

---

# Important Concepts to Remember

```text
PV
→ Physical storage prepared for LVM

VG
→ Storage pool made from one or more PVs

LV
→ Virtual block device created from the VG

Filesystem
→ ext4 / XFS / etc.

Mount Point
→ Directory where the filesystem is accessed
```

The complete structure is:

```text
Disk / Partition
       │
       ▼
Physical Volume (PV)
       │
       ▼
Volume Group (VG)
       │
       ▼
Logical Volume (LV)
       │
       ▼
Filesystem
       │
       ▼
Mount Point
```

---

# Quick Revision

```text
pvcreate
→ Create a Physical Volume

vgcreate
→ Create a Volume Group

vgextend
→ Add another PV to an existing VG

lvcreate
→ Create a Logical Volume

lvextend
→ Increase the size of an LV

resize2fs
→ Grow an ext4 filesystem

xfs_growfs
→ Grow an XFS filesystem

lvextend -r
→ Extend the LV and resize the supported filesystem

pvs
→ Show Physical Volumes

vgs
→ Show Volume Groups

lvs
→ Show Logical Volumes
```

---

# Interview Answer

> **"LVM provides a flexible storage layer between physical disks and filesystems. The main layers are Physical Volume, Volume Group, and Logical Volume. In production, if a database filesystem is nearly full, I first check the filesystem, LV, and VG. If the Volume Group has free space, I can extend the Logical Volume and then grow the filesystem online. If the VG has no free space, I attach a new disk, create a Physical Volume using `pvcreate`, add it to the existing VG using `vgextend`, and then extend the LV using `lvextend`. For ext4 I can use `resize2fs`, and for XFS I use `xfs_growfs`. This approach can allow storage expansion without taking the application offline when the filesystem and workload support online growth."**
