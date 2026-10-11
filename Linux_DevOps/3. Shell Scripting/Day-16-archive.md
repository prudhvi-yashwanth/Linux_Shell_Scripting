# Linux - Day 16: Archive and Compress Files

## Overview

Today we learned how to:

- Create archives using `tar`
- View the contents of an archive
- Extract files from an archive
- Extract files to a specific directory
- Read a file from an archive without extracting it
- Create and extract ZIP files
- Understand the difference between archiving and compression

---

# 1. What is Archiving and Compression?

These are two related but different concepts.

### Archiving

**Archiving** means combining multiple files and directories into one file.

Example:

```text
app.log
app.conf
subdir/
```

becomes:

```text
backup.tar
```

A TAR archive does not necessarily compress the data.

### Compression

**Compression** reduces the size of the data.

Common compression formats include:

```text
gzip
bzip2
xz
```

For example:

```text
backup.tar
      │
      ▼
gzip compression
      │
      ▼
backup.tar.gz
```

So:

```text
tar
→ Archive files

gzip
→ Compress data
```

---

# 2. Create a TAR Archive

### Syntax

```bash
tar -cvf <archive-name> <files/directories>
```

Example:

```bash
tar -cvf backup.tar app.log app.conf subdir/
```

This creates:

```text
backup.tar
```

containing:

```text
app.log
app.conf
subdir/
```

---

# 3. Understanding the TAR Options

```bash
tar -cvf backup.tar app.log app.conf subdir/
```

| Option | Meaning |
|--------|---------|
| `-c` | Create a new archive |
| `-v` | Verbose; show files being processed |
| `-f` | Specify the archive filename |
| `backup.tar` | Name of the archive |
| `app.log` | File to include |
| `app.conf` | File to include |
| `subdir/` | Directory to include |

> **Important:** With `-f`, the archive filename follows immediately. The statement that `-f` must always be the last option before the filename is a common convention, but options can be arranged differently depending on the command syntax.

---

# 4. View Files Inside a TAR Archive

You do not need to extract the archive just to see what it contains.

Use:

```bash
tar -tvf backup.tar
```

Example:

```text
-rw-r--r-- user/user  1024 2026-08-23 app.log
-rw-r--r-- user/user   500 2026-08-23 app.conf
drwxr-xr-x user/user     0 2026-08-23 subdir/
```

This shows:

- Permissions
- Owner
- Group
- File size
- Date/time
- File name

The options are:

```text
-t → List archive contents
-v → Verbose output
-f → Read from specified archive
```

---

# 5. Extract a TAR Archive

To extract the archive into the current directory:

```bash
tar -xvf backup.tar
```

Options:

```text
-x → Extract
-v → Verbose
-f → Archive filename
```

---

# 6. Extract to a Specific Directory

Use:

```bash
tar -xvf backup.tar -C /tmp
```

The `-C` option changes to the specified directory before extracting.

Example:

```bash
mkdir -p /tmp/backup
tar -xvf backup.tar -C /tmp/backup
```

The files will be extracted under:

```text
/tmp/backup
```

---

# 7. Extract Without Extracting Everything

Sometimes we only want to extract one file from the archive.

Example:

```bash
tar -xf backup.tar readme.md
```

This extracts only:

```text
readme.md
```

---

# 8. Read a File Without Extracting It

You can print a file stored inside a TAR archive directly to the terminal.

Use:

```bash
tar -xf backup.tar readme.md -O
```

The `-O` option sends the extracted file's contents to **standard output** instead of writing the file to disk.

Example:

```bash
tar -xf readme.tar readme2.md -O
```

Output:

```text
This is the content of readme2.md
```

Nothing is extracted as a file in the current directory.

This is useful when:

- Quickly checking a configuration file
- Inspecting a README
- Checking archived logs
- Debugging backup contents

---

# 9. TAR Command Summary

```text
-c → Create archive
-x → Extract archive
-t → List archive contents
-v → Verbose output
-f → Specify archive filename
-C → Extract/change directory
-O → Write extracted file to stdout
```

---

# 10. TAR Archive Examples

### Create

```bash
tar -cvf backup.tar app.log app.conf subdir/
```

### List

```bash
tar -tvf backup.tar
```

### Extract

```bash
tar -xvf backup.tar
```

### Extract to a directory

```bash
tar -xvf backup.tar -C /tmp/backup
```

### Extract one file

```bash
tar -xf backup.tar app.log
```

### Read one file without extracting

```bash
tar -xf backup.tar app.log -O
```

---

# 11. Create a Gzip-Compressed TAR Archive

A normal `.tar` archive only groups files together; it does not compress them.

To create a gzip-compressed TAR archive:

```bash
tar -czvf backup.tar.gz app.log app.conf subdir/
```

The additional option is:

```text
-z → gzip compression
```

The flow is:

```text
Files
  │
  ▼
tar
  │
  ▼
Archive
  │
  ▼
gzip
  │
  ▼
backup.tar.gz
```

---

# 12. View a `.tar.gz` Archive

```bash
tar -tzvf backup.tar.gz
```

Example:

```text
-rw-r--r-- user/user  1024 ... app.log
-rw-r--r-- user/user   500 ... app.conf
```

---

# 13. Extract a `.tar.gz` Archive

```bash
tar -xzvf backup.tar.gz
```

To extract to a specific location:

```bash
tar -xzvf backup.tar.gz -C /tmp/backup
```

---

# 14. TAR Compression Types

TAR can be combined with different compression methods.

| Extension | Command Option | Compression |
|-----------|----------------|-------------|
| `.tar` | None | No compression |
| `.tar.gz` | `-z` | gzip |
| `.tar.bz2` | `-j` | bzip2 |
| `.tar.xz` | `-J` | xz |

Examples:

```bash
tar -czvf backup.tar.gz files/
```

```bash
tar -cjvf backup.tar.bz2 files/
```

```bash
tar -cJvf backup.tar.xz files/
```

---

# 15. ZIP and UNZIP

ZIP is another common archive and compression format.

Unlike a plain TAR archive, ZIP normally combines **archiving and compression** in one format.

---

# 16. Create a ZIP File

### Syntax

```bash
zip -r <zip-file> <files/directories>
```

Example:

```bash
zip -r backup.zip app.log app.conf subdir/
```

The `-r` option means:

```text
Recursive
```

It allows directories and their contents to be included.

---

# 17. List ZIP Contents

```bash
unzip -l backup.zip
```

This lists the files without extracting them.

Example:

```text
Length   Date       Time   Name
1024     2026-08-23        app.log
500      2026-08-23        app.conf
```

---

# 18. Extract ZIP to a Specific Directory

```bash
unzip backup.zip -d /tmp/unzipped
```

The `-d` option specifies the destination directory.

Example:

```bash
mkdir -p /tmp/unzipped
unzip backup.zip -d /tmp/unzipped
```

---

# 19. ZIP vs TAR

| TAR | ZIP |
|-----|-----|
| Primarily an archive format | Archive + compression format |
| Common in Linux/Unix | Common across Linux, Windows, macOS |
| Compression is normally added separately | Compression is built into the format |
| Common for Linux backups and source packages | Common for portable file sharing |
| `.tar`, `.tar.gz`, `.tar.xz` | `.zip` |

---

# 20. DevOps Use Cases

Archiving and compression are commonly used for:

- Application backups
- Log backups
- Configuration backups
- Source code packaging
- Artifact creation
- Moving files between servers
- Log archival
- Disaster recovery

Example:

```text
Application Logs
      │
      ▼
tar
      │
      ▼
backup.tar
      │
      ▼
gzip
      │
      ▼
backup.tar.gz
```

---

# 21. Backup Example

Suppose we have:

```text
/etc/myapp/
├── app.conf
├── database.conf
└── logging.conf
```

Create a backup:

```bash
sudo tar -czvf myapp-config-2026-08-23.tar.gz /etc/myapp/
```

List its contents:

```bash
tar -tzvf myapp-config-2026-08-23.tar.gz
```

Extract it into a test directory:

```bash
mkdir -p /tmp/myapp-restore
tar -xzvf myapp-config-2026-08-23.tar.gz -C /tmp/myapp-restore
```

---

# 22. Useful Command Reference

```bash
# Create TAR archive
tar -cvf backup.tar files/

# List TAR contents
tar -tvf backup.tar

# Extract TAR archive
tar -xvf backup.tar

# Extract TAR to another directory
tar -xvf backup.tar -C /tmp/backup

# Read a file inside TAR without writing it to disk
tar -xf backup.tar readme.md -O

# Create gzip-compressed TAR
tar -czvf backup.tar.gz files/

# List TAR.GZ contents
tar -tzvf backup.tar.gz

# Extract TAR.GZ
tar -xzvf backup.tar.gz

# Create ZIP
zip -r backup.zip files/

# List ZIP contents
unzip -l backup.zip

# Extract ZIP
unzip backup.zip

# Extract ZIP to another directory
unzip backup.zip -d /tmp/unzipped
```

---

# Quick Revision

```text
tar
→ Create and manage archives

-c
→ Create

-x
→ Extract

-t
→ List contents

-v
→ Verbose

-f
→ Specify archive file

-z
→ gzip compression

-C
→ Change extraction directory

-O
→ Print extracted file content to stdout

zip -r
→ Create ZIP recursively

unzip -l
→ List ZIP contents

unzip -d
→ Extract ZIP to a specific directory
```

---

# Important Difference to Remember

```text
tar
→ Combines files into one archive.

tar.gz
→ Combines files + gzip compression.

zip
→ Combines files + compression in one format.
```
