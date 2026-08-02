# Linux - Day 3

# Viewing File Contents

Linux provides several commands to read and inspect file contents. Each command serves a different purpose depending on the requirement.

---

## `cat` Command

```bash
cat report1.txt
```

**Description:**

Displays the entire contents of a file on the terminal.

### Use Case

Useful for viewing small files.

> **Note:** Avoid using `cat` for very large files, as it prints the entire file at once.

---

## `head` Command

```bash
head report1.txt
```

**Description:**

Displays the first **10 lines** of a file by default.

### Display the First 3 Lines

```bash
head -n 3 report1.txt
```

### Option

- `-n` → Specifies the number of lines to display.

---

## `tail` Command

```bash
tail report1.txt
```

**Description:**

Displays the last **10 lines** of a file by default.

### Display the Last 5 Lines

```bash
tail -n 5 report1.txt
```

### Option

- `-n` → Specifies the number of lines to display.

---

## Monitor a File in Real Time

```bash
tail -f /var/log/syslog
```

**Description:**

Displays new lines as they are written to the file.

The `-f` option stands for **follow**.

This command is commonly used to monitor:

- Application logs
- System logs
- Server logs

Press **Ctrl + C** to stop monitoring.

---

# Count Lines

```bash
wc -l report1.txt
```

**Description:**

Counts the number of lines in a file.

### Option

- `-l` → Count lines only.

Example output:

```text
25 report1.txt
```

---

# View Large Files

```bash
less report1.txt
```

**Description:**

Opens the file in a scrollable viewer.

Useful shortcuts:

| Key | Action |
|------|--------|
| `Space` | Next page |
| `b` | Previous page |
| `/text` | Search inside the file |
| `n` | Next search result |
| `Shift + N` | Previous search result |
| `q` | Quit |

`less` is recommended for viewing large files because it does not load the entire file into memory at once.

---

# Common Options

| Option | Description |
|---------|-------------|
| `-n` | Display the specified number of lines |
| `-f` | Follow the file and display live updates |
| `-l` | Count the number of lines (`wc`) |

---

# Real-Time Scenario: `command not found`

### Scenario

You create a shell script:

```bash
script.sh
```

The file exists in the current directory, but when you run:

```bash
script.sh
```

You get:

```text
command not found
```

### Why Does This Happen?

When you type a command, Bash searches only the directories listed in the **PATH** environment variable.

Example PATH:

```text
/usr/local/bin
/usr/bin
/bin
```

For security reasons, the **current directory (`.`)** is **not included** in the PATH by default.

Therefore, Bash cannot find `script.sh`, even though it exists in the current directory.

---

## Correct Way to Run the Script

```bash
./script.sh
```

Here:

- `.` → Represents the current directory.
- `./script.sh` tells Bash to execute the script from the current directory.

---

# Check the PATH Variable

View the PATH environment variable:

```bash
echo $PATH
```

Example output:

```text
/usr/local/bin:/usr/bin:/bin
```

Notice that `.` (current directory) is not present.

---

# Important Note: `find -exec` vs `xargs`

When working with the `find` command, there are multiple ways to execute another command on the matching files.

---

## `-exec ... \;`

```bash
find . -name "*.txt" -exec cat {} \;
```

### Description

Runs the command **once for each matching file**.

For example, if there are three files:

```text
a.txt
b.txt
c.txt
```

Bash executes:

```bash
cat a.txt
cat b.txt
cat c.txt
```

> **Note:** A new process is created for each file, so this approach is slower when processing many files.

---

## `-exec ... +`

```bash
find . -name "*.txt" -exec cat {} +
```

### Description

Passes multiple matching files to the command in fewer executions.

Example:

```bash
cat a.txt b.txt c.txt
```

This is more efficient than `-exec ... \;`.

---

## Using `xargs`

```bash
find . -name "*.txt" | xargs cat
```

### Description

`xargs` reads the output from `find` and passes it as arguments to another command.

Equivalent to:

```bash
cat a.txt b.txt c.txt
```

This is similar in performance to `-exec ... +`.

---

# Comparison

| Method | Execution | Performance |
|---------|-----------|-------------|
| `-exec CMD {} \;` | One command per file | Slower |
| `-exec CMD {} +` | Multiple files per command | Faster |
| `xargs CMD` | Multiple files per command | Faster |

> **Best Practice:** Use `-exec {} +` or `xargs` when processing a large number of files for better performance.

---

# Summary

Today you learned:

- Viewing files using `cat`
- Displaying the beginning of a file using `head`
- Displaying the end of a file using `tail`
- Monitoring log files using `tail -f`
- Counting lines using `wc -l`
- Viewing large files using `less`
- Understanding the `PATH` environment variable
- Why `./script.sh` is required to execute scripts from the current directory
- The difference between `-exec ... \;`, `-exec ... +`, and `xargs`

---

# End of Day 3
