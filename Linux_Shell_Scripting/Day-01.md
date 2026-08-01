# Linux - Day 1

## Environment Setup

Install the required tools and create a Linux virtual machine using Multipass.

```bash
# Install Homebrew (macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Multipass
brew install --cask multipass

# Create a virtual machine
multipass launch --name devops-lab --cpus 2 --memory 2G --disk 10G

# Connect to the VM
multipass shell devops-lab
```

> **Note:**
> Multipass is a lightweight tool that creates Ubuntu virtual machines. It is useful for learning Linux without affecting your main operating system.

---

# Commands Learned Today

## 1. Check Current Directory

```bash
pwd
```

**Description:**
Prints the current working directory. It shows your current location in the Linux file system.

---

## 2. Check Logged-in User

```bash
whoami
```

**Description:**
Displays the username of the currently logged-in user.

---

## 3. List Files and Directories

```bash
ls -la
```

**Description:**
Lists all files and directories in the current location.

**Options:**

- `-l` → Displays detailed information (permissions, owner, size, date, etc.).
- `-a` → Shows hidden files (files starting with `.`).

---

## 4. List Files in Another Directory

```bash
ls -la /var
```

**Description:**
Lists all files and directories inside the `/var` directory, regardless of your current location.

---

# Navigating Directories

## Go to `/etc`

```bash
cd /etc
```

**Purpose:**
The `/etc` directory stores system configuration files.

---

## Go to `/var`

```bash
cd /var
```

**Purpose:**
The `/var` directory stores variable data such as:

- Logs
- Mail
- Cache
- Spool files
- Temporary application data

---

## Go to Home Directory

```bash
cd /home
```

**Purpose:**
Contains the home directories of all users.

Example:

```text
/home/ubuntu
/home/john
```

---

## Go to `/bin`

```bash
cd /bin
```

**Purpose:**
Contains essential user command binaries such as:

- `ls`
- `cp`
- `mv`
- `rm`
- `cat`

> **Note:** On modern Ubuntu systems, `/bin` is usually a symbolic link to `/usr/bin`.

---

## Go to Your Home Directory

```bash
cd ~
```

or simply

```bash
cd
```

**Description:**
Takes you to your current user's home directory.

---

# Creating Directories

## Create Nested Directories

```bash
mkdir -p practice/day1
```

**Description:**

- Creates the directory if it does not exist.
- Creates parent directories automatically.
- Does not show an error if the directory already exists.

Move into the directory:

```bash
cd practice/day1
```

---

# Creating Files

## Create Empty Files

```bash
touch file1.txt
```

**Description:**
Creates an empty file. If the file already exists, it updates its timestamp.

---

# Create a Directory

```bash
mkdir backup
```

**Description:**
Creates a directory named `backup`.

---

# Move or Rename Files

```bash
mv draft.txt final.txt
```

**Description:**

- Renames `draft.txt` to `final.txt`.
- Can also be used to move files between directories.

Example:

```bash
mv file.txt backup/
```

---

# Copy Files and Directories

```bash
cp -r source_folder destination_folder
```

**Description:**

- `cp` → Copy files.
- `-r` → Recursive. Required when copying directories.

Example:

```bash
cp -r backup backup-copy
```

---

# Delete Files

```bash
rm backup2/notes-copy.txt
```

**Description:**
Deletes a single file.

---

# Delete Empty Directory

```bash
rmdir backup2
```

**Description:**
Deletes a directory only if it is empty.

---

# Find Files

```bash
find ~/practice -name "*.txt"
```

**Description:**
Searches for all files ending with `.txt` inside the `~/practice` directory.

---

# What is Spool?

**SPOOL** stands for **Simultaneous Peripheral Operations On-Line**.

A spool is a temporary storage location where the operating system keeps data waiting to be processed by another program or device.

### Common Uses

- Print queue
- Mail queue

### Location

```text
/var/spool/
```

Examples:

```text
/var/spool/cups    # Print queue
/var/spool/mail    # Mail queue
```

---

# Wildcards

Move to the practice directory.

```bash
cd ~/practice/day1
```

Create sample files.

```bash
touch report1.txt report2.txt report3.txt notes.md draft.md
```

### List all `.txt` files

```bash
ls *.txt
```

Matches every file ending with `.txt`.

---

### List files starting with `report`

```bash
ls report*
```

Matches every file whose name starts with `report`.

---

### Match Exactly One Character

```bash
ls report?.txt
```

The `?` wildcard matches exactly one character.

Examples:

```text
report1.txt
report2.txt
reportA.txt
```

It does **not** match:

```text
report10.txt
```

---

### Match Multiple Extensions

```bash
ls *.{txt,md}
```

Lists files ending with either:

- `.txt`
- `.md`

---

# Summary

Today you learned:

- Linux environment setup using Multipass
- Navigation commands (`pwd`, `cd`)
- User information (`whoami`)
- Listing files (`ls`)
- Creating files and directories (`touch`, `mkdir`)
- Moving and renaming files (`mv`)
- Copying files and directories (`cp`)
- Deleting files and directories (`rm`, `rmdir`)
- Finding files (`find`)
- Understanding the `/var/spool` directory
- Using wildcards (`*`, `?`, `{}`) to match file names

---

# End of Day 1
