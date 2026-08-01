# Linux - Bash Basics

## What is Bash?

**Bash** stands for **Bourne Again SHell**.

It is a **shell** (command-line interpreter) that allows you to interact with the Linux operating system by entering commands.

Bash follows the **REPL** model:

- **R** – Read (reads the command you type)
- **E** – Evaluate (processes the command)
- **P** – Print (shows the output)
- **L** – Loop (waits for the next command)

### Example

```bash
echo hi
```

**Output**

```text
hi
```

Bash reads the command, executes it, prints the result, and waits for the next command.

---

# Current Working Directory

```bash
pwd
```

**Description:**

Prints the current working directory.

Example:

```text
/home/dave
```

> **Note:** The home directory is usually `/home/<username>` on Linux systems.

---

# List Files

```bash
ls
```

Lists the files and directories in the current folder.

---

# Delete a File

```bash
rm file.txt
```

Deletes the file permanently.

> **Important:** Files deleted using `rm` do **not** go to the Recycle Bin or Trash. They are permanently removed.

---

# Change Directory

```bash
cd foo
```

Moves into the `foo` directory.

Verify your current location:

```bash
pwd
```

---

# Clear the Terminal

```bash
clear
```

or press

```text
Ctrl + L
```

Both commands clear the terminal screen.

---

# Create a File

```bash
touch new-file.txt
```

Creates an empty file.

> **Note:** Whether you create a file using the Command Line (CLI) or Graphical User Interface (GUI), both use the same file system.

---

# Basic File Manipulation

Create files:

```bash
touch lesson1.txt
touch lesson2.txt
touch lesson3.txt
```

Rename a file:

```bash
mv lesson3.txt lesson4.txt
```

The `mv` command is used to:

- Move files
- Rename files

Example:

```bash
mv old-name.txt new-name.txt
```

> **Important:** If the destination file already exists, `mv` overwrites it without asking for confirmation.

---

# Delete Multiple Files

Example:

```bash
rm lesson-*.txt
```

Deletes all files matching the pattern.

Example:

```text
lesson-1.txt
lesson-2.txt
lesson-3.txt
```

---

# Interactive Delete

Create sample files:

```bash
touch lesson-1.txt
touch lesson-2.txt
```

Delete with confirmation:

```bash
rm -i lesson*
```

The `-i` option asks for confirmation before deleting each file.

---

# Alias

An **alias** is a shortcut for a command.

Example:

```bash
alias rm='rm -i'
```

Now every time you run:

```bash
rm lesson*
```

Bash asks for confirmation before deleting files.

View the alias:

```bash
alias rm
```

View all aliases:

```bash
alias
```

---

# Command History

```bash
history
```

Displays the list of previously executed commands.

---

# Hidden Files

In Linux, files beginning with a **dot (`.`)** are hidden files.

Create a hidden file:

```bash
touch .file.txt
```

View hidden files:

```bash
ls -a
```

The `-a` option displays all files, including hidden files.

---

# Special Directory Symbols

## Current Directory

```text
.
```

or

```text
./
```

Represents the current directory.

Example:

```bash
./script.sh
```

Runs the script from the current directory.

---

## Parent Directory

```text
..
```

or

```text
../
```

Represents the parent directory (one level above the current directory).

Example:

```bash
cd ..
```

Moves one directory up.

---

## Previous Directory

```bash
cd -
```

Moves back to the previously visited directory.

---

# Searching File Contents with grep

## Display File Content

```bash
cat file.txt
```

Prints the contents of a file.

---

## Search for a Word

```bash
grep dave file.txt
```

Displays lines containing the word `dave`.

---

## Match Beginning of a Line

```bash
grep '^dave' file.txt
```

The `^` symbol matches the beginning of a line.

Example:

```text
dave is here
```

---

## Match End of a Line

```bash
grep 'dave$' file.txt
```

The `$` symbol matches the end of a line.

Example:

```text
hello dave
```

---

## Print Lines After a Match

```bash
grep -A1 "b" file.txt
```

Prints:

- The matching line
- One line after it

---

## Print Lines Before a Match

```bash
grep -B1 "b" file.txt
```

Prints:

- One line before the match
- The matching line

---

## Print Lines Before and After a Match

```bash
grep -C3 "b" file.txt
```

Prints:

- Three lines before
- The matching line
- Three lines after

> **Correction:** Your original command used `-C33`, but based on the description, `-C3` is the correct command.

---

## Case-Insensitive Search

```bash
grep -i dave file.txt
```

Matches:

```text
Dave
DAVE
dAvE
dave
```

---

## Print Only the Matched Pattern

```bash
grep -o '^d.' file.txt
```

Options:

- `-o` → Prints only the matched text.
- `^` → Matches the beginning of the line.
- `.` → Matches any single character.

Example:

```text
Input:
dave
dog
cat

Output:
da
do
```

---

## Combine Multiple Options

```bash
grep -i -o '^d.' file.txt
```

or

```bash
grep -io '^d.' file.txt
```

Performs a case-insensitive search and prints only the matched pattern.

---

# Viewing Large Files

## less

```bash
less /usr/share/dict/words
```

The `less` command allows you to view large files one page at a time.

Useful shortcuts:

| Key | Action |
|------|--------|
| `/text` | Search for text |
| `n` | Next search result |
| `Shift + N` | Previous search result |
| `Space` | Next page |
| `b` | Previous page |
| `q` | Quit |

---

# Manual Pages

```bash
man ls
```

Displays the manual page for the `ls` command.

The manual contains:

- Description
- Syntax
- Available options
- Examples

Example:

```bash
man grep
man pwd
man mv
```

---

# Summary

Today you learned:

- What Bash is and how the REPL model works
- Navigating directories using `cd` and `pwd`
- Creating files with `touch`
- Renaming and moving files using `mv`
- Deleting files using `rm`
- Interactive delete with `rm -i`
- Creating command shortcuts using `alias`
- Viewing command history with `history`
- Working with hidden files
- Understanding `.` , `..`, and `cd -`
- Searching file contents using `grep`
- Viewing large files using `less`
- Reading command documentation using `man`

---

# End of Notes

