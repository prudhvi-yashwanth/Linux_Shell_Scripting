# Linux - Day 2

## `file` Command

The `file` command identifies the **actual type of a file** by examining its contents instead of relying on the file extension.

### Syntax

```bash
file <filename>
```

### Example

```bash
file data.txt
```

**Output (Example):**

```text
data.txt: gzip compressed data
```

Even though the file has a `.txt` extension, the `file` command reveals that it is actually a **gzip-compressed file**.

### Real-Time Scenario

Suppose someone gives you a file named `data.txt`, but your application fails to read it as a text file.

Instead of assuming the extension is correct, run:

```bash
file data.txt
```

It may reveal that the file is actually:

- A gzip archive
- A binary file
- A PDF
- An image
- A shell script

This helps you identify the real file type and saves debugging time.

---

# `find` Command

The `find` command is used to search for files and directories.

You can search based on:

- File name
- File type
- Size
- Modification time
- Permissions
- Owner
- Extension

---

## Find Files by Name

```bash
find . -name "*.txt"
```

Searches for all `.txt` files in the current directory and its subdirectories.

---

## Case-Insensitive Search

```bash
find . -iname "*.TXT"
```

The `-iname` option performs a case-insensitive search.

Matches:

```text
file.txt
FILE.TXT
Report.Txt
```

---

## Find Only Files

```bash
find . -type f
```

Displays only regular files.

---

## Find Only Directories

```bash
find . -type d
```

Displays only directories.

---

## Find Recently Modified Files

```bash
find . -mtime -1
```

Finds files modified within the last **1 day (24 hours)**.

---

## Find Non-Empty Files

```bash
find . -size +0
```

Finds files larger than **0 bytes**.

> **Note:** This helps identify files that are not empty.

---

## Find and Delete Files

```bash
find . -name "*.md" -delete
```

Finds all Markdown files and deletes them.

> **Warning:** The `-delete` option permanently removes files. Double-check your search before using it.

---

# Real-Time Scenario

### Scenario

A production server reports that the disk is almost full.

You need to find all files:

- Larger than **100 MB**
- Modified within the last **2 days**

### Command

```bash
find / -type f -size +100M -mtime -2 2>/dev/null
```

### Explanation

- `/` → Search the entire file system.
- `-type f` → Search only files.
- `-size +100M` → Files larger than 100 MB.
- `-mtime -2` → Modified in the last 2 days.
- `2>/dev/null` → Hide permission denied errors.

---

# Execute a Command on Each File

## Display File Contents

```bash
find . -name "*.txt" -exec cat {} \;
```

Runs the `cat` command on every matching `.txt` file.

### Explanation

- `{}` → Represents the matched file.
- `\;` → Ends the `-exec` command.

---

## Delete Matching Files

```bash
find . -name "*.md" -exec rm {} \;
```

Deletes each matching Markdown file one by one.

> **Tip:** Using `-delete` is usually faster, but `-exec` allows you to run any command.

---

# Using `xargs`

The `xargs` command converts standard input into command-line arguments for another command.

It is commonly used with:

- `find`
- `grep`
- `cat`
- `echo`

---

## Count Lines in Multiple Files

```bash
find . -name "*.txt" | xargs wc -l
```

Counts the number of lines in all matching `.txt` files.

---

# Real-Time Scenario

### Compress Old Log Files

Suppose your `/var/log` directory contains many old log files.

Compress all `.log` files older than **7 days**.

```bash
find /var/log -name "*.log" -mtime +7 -exec gzip {} \;
```

### Explanation

- `-mtime +7` → Older than 7 days.
- `gzip` → Compress each file.

---

# Delete Files Safely with `xargs`

```bash
find . -name "*.log" -print0 | xargs -0 rm
```

### Why use `-print0` and `-0`?

Some file names contain:

- Spaces
- Tabs
- Newlines

Using:

```bash
-print0
```

and

```bash
-0
```

ensures such file names are handled safely.

---

# Run a Command for Each Input

Suppose `domains.txt` contains:

```text
google.com
github.com
openai.com
```

Run:

```bash
cat domains.txt | xargs -n 1 host
```

### Explanation

- `-n 1` → Executes the command once for each line.

Equivalent to:

```bash
host google.com
host github.com
host openai.com
```

This is useful when a command accepts only one argument at a time.

---

# Ask Before Executing

```bash
find . -name "*.tmp" | xargs -p rm
```

The `-p` option prompts for confirmation before executing the command.

Example:

```text
rm file1.tmp ?...y
rm file2.tmp ?...n
```

This is useful when performing bulk deletions.

---

# File Permissions

Create a script:

```bash
touch test.sh
```

Check its permissions:

```bash
ls -l test.sh
```

Example output:

```text
-rw-r--r-- 1 ubuntu ubuntu 0 Jul 30 10:15 test.sh
```

Notice that there is **no `x` (execute) permission**.

---

## Make the Script Executable

```bash
chmod +x test.sh
```

Check the permissions again:

```bash
ls -l test.sh
```

Example output:

```text
-rwxr-xr-x 1 ubuntu ubuntu 0 Jul 30 10:15 test.sh
```

The `x` indicates that the file is executable.

---

# Real-Time Scenario

You create a shell script:

```bash
./deploy.sh
```

Instead of running, you get:

```text
Permission denied
```

The most common reason is that the script does not have execute permission.

Fix it using:

```bash
chmod +x deploy.sh
```

Then run:

```bash
./deploy.sh
```

---

# Summary

Today you learned:

- How the `file` command identifies the actual file type
- Searching files and directories using `find`
- Finding files by name, type, size, and modification time
- Deleting files using `find`
- Running commands on matching files using `-exec`
- Using `xargs` to pass input to another command
- Safely handling filenames with spaces using `-print0` and `-0`
- Compressing old log files using `gzip`
- Running commands one input at a time using `xargs -n`
- Asking for confirmation with `xargs -p`
- Making shell scripts executable using `chmod +x`

---

# End of Day 2
