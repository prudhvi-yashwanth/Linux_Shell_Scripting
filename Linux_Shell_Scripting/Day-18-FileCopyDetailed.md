## Linux - Day 17: SCP, Rsync, Rclone, and Netcat

## Overview

Today we learned different ways to transfer files between Linux systems and cloud storage.

The main tools are:

```text
scp
→ Simple and secure file copy using SSH

rsync
→ Efficient file and directory synchronization

rclone
→ File synchronization and transfer for cloud/object storage

nc + tar
→ Fast direct transfer over a trusted network
```

---

## 1. SCP - Secure Copy

`scp` stands for **Secure Copy**.

It is used to securely copy files and directories between:

- Local machine and remote server
- Remote server and local machine
- One remote server and another remote server

It uses SSH for authentication and encryption.

### Basic Syntax

```bash
scp <source> <destination>
```

Example:

```bash
scp file.txt user@host:/remote/path/
```

---

## 2. Local to Remote

```bash
scp file.txt user@host:/remote/path/
```

Example:

```bash
scp app.log ubuntu@192.168.1.50:/tmp/
```

Flow:

```text
Local Machine
     │
     │ SCP over SSH
     ▼
Remote Server
     │
     ▼
/tmp/app.log
```

---

## 3. Remote to Local

```bash
scp user@host:/remote/path/file.txt ./
```

Example:

```bash
scp ubuntu@192.168.1.50:/tmp/app.log ./
```

Here:

```text
./
```

means the current local directory.

---

## 4. Copy a Directory

Use:

```bash
scp -r localdir/ user@host:/remote/path/
```

The `-r` option means:

```text
Recursive
```

It is required when copying directories and their contents.

Example:

```bash
scp -r app/ ubuntu@192.168.1.50:/opt/
```

---

## 5. Use a Non-Default SSH Port

If SSH is running on a port other than `22`:

```bash
scp -P 2222 file.txt user@host:/remote/path/
```

Important:

```text
-P
→ SSH port
```

The capital `P` is important.

Do not confuse it with:

```text
-p
→ Preserve file attributes
```

---

## 6. Preserve File Attributes

```bash
scp -p file.txt user@host:/remote/path/
```

The `-p` option attempts to preserve:

- Modification times
- Access times
- Permissions

---

## 7. Compress During Transfer

Use:

```bash
scp -C file.txt user@host:/remote/path/
```

The `-C` option enables compression during transfer.

This can help when transferring compressible data over slower links.

> **Note:** Compression is not always faster. For already-compressed files such as `.zip`, `.gz`, `.jpg`, or `.mp4`, it may provide little benefit and can add CPU overhead.

---

## 8. Copy Between Two Remote Hosts

Depending on the OpenSSH `scp` implementation, you can copy directly between two remote hosts:

```bash
scp user1@host1:/path/file.txt user2@host2:/path/
```

Example:

```bash
scp ubuntu@10.0.0.5:/tmp/test.txt ec2-user@10.0.0.10:/tmp/
```

> **Important:** SSH credentials and network connectivity must be available for the required hosts. For complex multi-hop transfers, using `scp` from one of the hosts or using SSH agent forwarding/configuration may be easier.

---

## 9. Understand Source and Destination

In:

```bash
scp user@IPaddr:/tmp/test.txt ./
```

we have:

```text
SOURCE
→ user@IPaddr:/tmp/test.txt

DESTINATION
→ ./
```

The basic rule is:

```text
scp <source> <destination>
```

---

## 10. SCP Options Quick Reference

| Option | Meaning |
|--------|---------|
| `-r` | Recursively copy directories |
| `-P` | Specify SSH port |
| `-p` | Preserve timestamps and permissions |
| `-C` | Enable compression |
| `-i` | Specify a private key |

Example:

```bash
scp -i ~/.ssh/aws-prod-key.pem \
    -P 2222 \
    app.tar.gz \
    ec2-user@host:/tmp/
```

---

## 11. Limitation of SCP

A major limitation of `scp` is that it generally transfers the **entire file** again when you copy it.

Example:

```text
File = 10 GB

First copy
→ Transfer 10 GB

One small change

Second copy
→ Transfer the complete 10 GB again
```

For repeated or large transfers, `rsync` is usually more efficient.

---

## 12. Rsync

`rsync` is used to efficiently synchronize files and directories.

A major advantage is that it can transfer only the data that differs between source and destination.

Example:

```text
Source = 10 GB
Destination = 10 GB

Only 20 MB changed

rsync
→ Transfers only the required differences
```

It is useful for:

- Large directories
- Backups
- Repeated deployments
- Server synchronization
- Incremental transfers
- Resuming interrupted transfers

---

## 13. Basic Rsync Syntax

```bash
rsync <source> <destination>
```

Example:

```bash
rsync -avz source/ user@host:/remote/path/
```

---

## 14. Rsync Common Options

```text
-a
→ Archive mode

-v
→ Verbose output

-z
→ Compress data during transfer

-P
→ Show progress and keep partial files so interrupted transfers can resume
```

### `-a` Archive Mode

```bash
-a
```

Archive mode preserves important file attributes and recursively copies directories.

It includes behaviour such as:

- Recursive copying
- Permissions
- Timestamps
- Symbolic links
- Ownership-related attributes where permitted

---

## 15. Rsync with Progress and Resume

```bash
rsync -avzP source/ user@host:/remote/path/
```

This is a very useful command for large transfers.

The `-P` option combines:

```text
--progress
--partial
```

So you can see transfer progress and keep partially transferred files.

---

## 16. `--delete`

The `--delete` option removes files from the destination that no longer exist in the source.

Example:

```bash
rsync -avz --delete source/ user@host:/remote/path/
```

This makes the destination closely match the source.

Example:

```text
Source:
file1
file2

Destination:
file1
file2
file3
```

After:

```bash
rsync -av --delete source/ destination/
```

the destination becomes:

```text
file1
file2
```

and:

```text
file3
```

is deleted.

> **Warning:** `--delete` can delete data. Use it carefully.

---

## 17. Dry Run

Before using destructive options such as `--delete`, perform a dry run:

```bash
rsync -avz --delete -n source/ user@host:/remote/path/
```

The `-n` option means:

```text
Dry run
```

It shows what would happen without actually making the changes.

A safe workflow is:

```text
Dry Run
   ↓
Review Changes
   ↓
Real Rsync
```

---

## 18. Rsync Source Directory Behaviour

Trailing slashes are very important.

### With trailing slash

```bash
rsync -av source/ destination/
```

This copies the **contents** of `source` into `destination`.

Example:

```text
source/
├── file1
└── file2

destination/
```

Result:

```text
destination/
├── file1
└── file2
```

---

## 19. Without Trailing Slash

```bash
rsync -av source destination/
```

This copies the **source directory itself** into the destination.

Result:

```text
destination/
└── source/
    ├── file1
    └── file2
```

### Easy Rule

```text
source/
→ Copy contents

source
→ Copy the directory itself
```

This is a very common interview and real-world troubleshooting point.

---

## 20. Local to Remote with Rsync

```bash
rsync -avzP /local/path/ user@host:/remote/path/
```

Example:

```bash
rsync -avzP ./app/ ubuntu@192.168.1.50:/opt/app/
```

---

## 21. Remote to Local with Rsync

Simply reverse the source and destination:

```bash
rsync -avzP user@host:/remote/path/ /local/path/
```

Example:

```bash
rsync -avzP ubuntu@192.168.1.50:/opt/app/ ./app/
```

---

## 22. SCP vs Rsync

| Feature | SCP | Rsync |
|---------|-----|-------|
| Uses SSH | Yes | Yes, by default |
| Simple one-time copy | Excellent | Good |
| Incremental transfer | No | Yes |
| Resume interrupted transfer | Limited | Yes |
| Synchronize directories | Basic | Excellent |
| Delete destination extras | No direct equivalent | `--delete` |
| Best for repeated large transfers | Not ideal | Yes |

### Simple Rule

```text
One-time simple copy
→ scp

Repeated / large / incremental transfer
→ rsync
```

---

## 23. Rclone

`rclone` is a command-line tool used to manage and transfer files between local systems and many cloud/object-storage providers.

It is conceptually similar to `rsync`, but it is designed for a large number of cloud and object-storage backends.

Common use cases include:

- Amazon S3
- Azure Blob Storage
- Google Cloud Storage
- Other object-storage providers

---

## 24. Configure Rclone

Run:

```bash
rclone config
```

This starts the interactive configuration process.

You can configure a remote storage provider.

---

## 25. List Configured Remotes

```bash
rclone listremotes
```

Example:

```text
mys3:
azureblob:
```

---

## 26. List Cloud Storage Contents

Example:

```bash
rclone ls mys3:my-bucket-name
```

This lists objects in the bucket.

> The exact remote syntax depends on how the remote was configured.

---

## 27. Local to Cloud

```bash
rclone copy /local/path/ mys3:my-bucket-name/path/
```

This copies files to the configured remote.

Example:

```bash
rclone copy ./backup/ mys3:my-bucket/backups/
```

---

## 28. Cloud to Local

```bash
rclone copy mys3:my-bucket-name/path/ /local/path/
```

Example:

```bash
rclone copy mys3:my-bucket/backups/ ./backup/
```

---

## 29. `rclone copy` vs `rclone sync`

This distinction is very important.

### `rclone copy`

```bash
rclone copy source destination
```

Copies new and changed files.

It does **not** delete files already present in the destination.

---

### `rclone sync`

```bash
rclone sync source destination
```

Makes the destination match the source and can delete destination files that no longer exist in the source.

This is similar in concept to:

```bash
rsync --delete
```

> **Warning:** `rclone sync` can delete destination data. Always use a dry run first when the destination contains important data.

---

## 30. Rclone Dry Run

```bash
rclone sync /local/path/ mys3:bucket/path/ --dry-run
```

This shows what would happen without making changes.

Recommended workflow:

```text
rclone sync --dry-run
        ↓
Review
        ↓
rclone sync
```

---

## 31. Rclone vs Rsync

| Tool | Main Use |
|------|----------|
| `rsync` | Local/server-to-server file synchronization |
| `rclone` | Cloud and object-storage synchronization |
| `scp` | Simple SSH-based file copy |

A simple way to remember:

```text
scp
→ Copy

rsync
→ Synchronize servers/filesystems

rclone
→ Synchronize cloud/object storage
```

---

## 32. Netcat + TAR

For a trusted internal network, `nc` (Netcat) can be combined with `tar` to stream files directly from one machine to another.

Example architecture:

```text
Sender
   │
   │ tar
   │
   ▼
  nc
   │
   │ Network
   ▼
  nc
   │
   ▼
 tar
   │
   ▼
Receiver
```

This avoids writing an intermediate archive file to disk.

---

## 33. Receiver

On the receiving machine:

```bash
nc -l 9999 | tar -xvf -
```

Depending on the Netcat implementation, you may see syntax such as:

```bash
nc -l -p 9999
```

The exact options can differ between `netcat-openbsd`, `netcat-traditional`, and other implementations.

---

## 34. Sender

On the sending machine:

```bash
tar -cvf - /path | nc <receiver-ip> 9999
```

Here:

```text
tar -cvf -
→ Write the TAR archive to standard output.

|
→ Pipe the archive to netcat.

nc <receiver-ip> 9999
→ Send the stream to the receiving machine.
```

---

## 35. Important Security Warning for Netcat

Plain Netcat transfer is **not encrypted**.

Therefore:

```text
Trusted private network
→ Potentially acceptable with proper controls

Public Internet
→ Do NOT use plain nc for sensitive data
```

For most server-to-server transfers, prefer:

```bash
rsync -avzP ...
```

because it normally runs over SSH and provides encrypted transport.

> **Correction:** Using `rsync` over SSH does **not** skip SSH encryption. SSH encryption is the reason it is secure. A plain `nc + tar` transfer may be faster in a trusted network because it avoids SSH encryption overhead, but it has no encryption by default.

---

## 36. Local Server to Local Server

For two machines on a trusted internal network:

### Recommended Default

```bash
rsync -avzP /local/path/ user@other-local-ip:/remote/path/
```

This is secure because the transfer is performed over SSH.

---

## 37. High-Speed Internal Transfer

If the network is trusted and encryption is intentionally not required:

### Receiver

```bash
nc -l 9999 | tar -xvf -
```

### Sender

```bash
tar -cvf - /path | nc other-ip 9999
```

This can be fast because it avoids SSH encryption.

> **Important:** Do not use this method over an untrusted network or the public internet for sensitive data.

---

## 38. Server to Remote Server Over the Internet

For a normal one-time transfer:

```bash
scp -r file_or_dir user@remote-ip:/path/
```

For repeated or large transfers:

```bash
rsync -avzP file_or_dir/ user@remote-ip:/path/
```

In most production cases, `rsync` is preferred for recurring large transfers.

---

## 39. Practical Decision Guide

Use:

```text
Need to copy one file?
        │
        ▼
       scp
```

```text
Need to sync a large directory repeatedly?
        │
        ▼
      rsync
```

```text
Need to transfer data to/from cloud storage?
        │
        ▼
      rclone
```

```text
Need very fast transfer over a trusted private network
and encryption is not required?
        │
        ▼
    nc + tar
```

---

## 40. Real-Time DevOps Examples

### Backup to Another Server

```bash
rsync -avzP /var/backups/ backup@10.0.0.20:/backup/
```

---

### Deploy Application Files

```bash
rsync -avzP ./build/ deploy@server:/var/www/app/
```

---

### Copy a Configuration File

```bash
scp nginx.conf ubuntu@server:/tmp/
```

---

### Upload Backup to Object Storage

```bash
rclone copy /var/backups/ mys3:company-backups/
```

---

### Mirror a Backup Directory

First test:

```bash
rclone sync /var/backups/ mys3:company-backups/ --dry-run
```

Then, if the output is correct:

```bash
rclone sync /var/backups/ mys3:company-backups/
```

---

## 41. Important Troubleshooting Commands

### SCP Debugging

```bash
scp -v file.txt user@host:/tmp/
```

---

### Rsync Debugging

```bash
rsync -avzP source/ user@host:/remote/path/
```

Use dry run:

```bash
rsync -avz --delete -n source/ user@host:/remote/path/
```

---

### Rclone Debugging

```bash
rclone ls remote:path
```

For more detailed logs:

```bash
rclone -vv copy /local/path/ remote:path/
```

---

## 42. Important Differences

### `scp`

```text
Copies the file
```

### `rsync`

```text
Synchronizes files
Transfers differences
Can resume partial transfers
```

### `rclone`

```text
Transfers and synchronizes
Cloud/object storage
```

### `nc + tar`

```text
Streams data directly
Very fast on trusted networks
No encryption by default
```

---

## 43. Quick Revision

```text
scp <source> <destination>
→ Secure copy over SSH

scp -r
→ Copy directories recursively

scp -P 2222
→ Use custom SSH port

scp -p
→ Preserve file attributes

scp -C
→ Compress transfer

rsync -avzP
→ Efficient transfer with archive mode,
  compression, progress, and resume support

rsync --delete
→ Remove destination files that no longer exist in source

rsync -n
→ Dry run

rclone copy
→ Copy to/from cloud storage without deleting destination extras

rclone sync
→ Make destination match source

rclone --dry-run
→ Preview changes

tar | nc
→ Stream an archive over a network

```

---

## 44. Key Interview Points

1. **Why use `rsync` instead of `scp`?**

> `rsync` is better for repeated and large transfers because it can transfer only changed data and can resume interrupted transfers.

2. **What is the difference between `rsync source/ destination/` and `rsync source destination/`?**

```text
source/
→ Copies the contents of source.

source
→ Copies the source directory itself.
```

3. **What does `--delete` do?**

> It removes files from the destination that are not present in the source. It should be used carefully and tested with a dry run first.

4. **What is the difference between `rclone copy` and `rclone sync`?**

```text
copy
→ Adds/updates files.
→ Does not delete destination extras.

sync
→ Makes destination match source.
→ Can delete destination extras.
```

5. **Why is `nc + tar` not a replacement for SSH?**

> Plain Netcat does not encrypt the transfer. It can be useful on a trusted private network when speed is important, but SSH-based tools such as `scp` and `rsync` are safer for untrusted networks.
