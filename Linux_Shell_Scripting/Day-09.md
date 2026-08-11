# Linux - Day 9: Processes and Process Management

## Overview

A **process** is a running instance of a program.

For example, when you run:

```bash
sleep 300
```

Linux creates a process for the `sleep` command.

Each process has a unique **Process ID (PID)**.

As a DevOps Engineer, process management is important for:

- Troubleshooting high CPU usage
- Troubleshooting high memory usage
- Finding a running application
- Stopping a stuck process
- Monitoring services
- Debugging application issues

---

# 1. `ps`

The `ps` command is used to view running processes.

```bash
ps
```

By default, it shows processes associated with the **current shell/session**.

Example:

```text
PID TTY          TIME CMD
1234 pts/0    00:00:00 bash
5678 pts/0    00:00:00 ps
```

---

# 2. `ps aux`

```bash
ps aux
```

Displays processes from **all users** in a detailed format, including processes that are not attached to a terminal.

Example:

```text
USER       PID  %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
ubuntu   131676  0.0  0.3  10084  6388 pts/0    Ss   09:19   0:00 -bash
```

---

## `ps aux` Options

The commonly used syntax is:

```bash
ps aux
```

| Option | Meaning |
|--------|---------|
| `a` | Show processes associated with terminals for all users |
| `u` | Show user-oriented information such as user, CPU, and memory |
| `x` | Include processes without a controlling terminal |

Together, `ps aux` gives a broad view of running processes.

> **Note:** `ps aux` is a BSD-style syntax. Another common form is `ps -ef`, which uses UNIX-style options and displays parent process information clearly.

---

# 3. Find a Specific Process

You can combine `ps`, `head`, and `grep`.

```bash
ps aux | head -n 1 && ps aux | grep bash
```

### Explanation

```bash
head -n 1
```

Displays the first line, which is the header.

```bash
grep bash
```

Searches for processes containing the word `bash`.

The output may look like:

```text
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
ubuntu    131676  0.0  0.3  10084  6388 pts/0    Ss   09:19   0:00 -bash
ubuntu    132172  0.0  0.0   7376  1984 pts/0    S+   09:30   0:00 grep --color=auto bash
```

---

# Important: `grep` Can Appear in Its Own Search

When you run:

```bash
ps aux | grep bash
```

you may see:

```text
grep --color=auto bash
```

This happens because the `grep bash` command itself contains the word `bash`.

A cleaner approach is:

```bash
ps aux | grep '[b]ash'
```

The `grep` process itself will normally not match this pattern.

An even better option for process searching is:

```bash
pgrep -a bash
```

---

# 4. Understanding `ps aux` Output

Example:

```text
USER       PID    %CPU  %MEM  VSZ    RSS   TTY   STAT  START  TIME  COMMAND
ubuntu     1234   0.5   1.2  10000  5000  pts/0 S     09:00  0:02  bash
```

| Column | Meaning |
|--------|---------|
| `USER` | User who owns the process |
| `PID` | Process ID |
| `%CPU` | CPU usage |
| `%MEM` | Memory usage |
| `VSZ` | Virtual memory size |
| `RSS` | Resident memory currently in RAM |
| `TTY` | Terminal associated with the process |
| `STAT` | Process state |
| `START` | Process start time |
| `TIME` | CPU time used by the process |
| `COMMAND` | Command used to start the process |

---

# 5. `top`

`top` displays running processes in real time.

```bash
top
```

It continuously updates information such as:

- CPU usage
- Memory usage
- Running processes
- Load average
- Process IDs

This is useful when troubleshooting system performance.

To exit:

```text
q
```

---

# 6. `htop`

`htop` is an interactive and more user-friendly alternative to `top`.

Install it on Ubuntu:

```bash
sudo apt update
sudo apt install htop
```

Run:

```bash
htop
```

It provides an easier interface for:

- Viewing processes
- Sorting by CPU
- Sorting by memory
- Searching processes
- Managing processes

---

# 7. Run a Process in the Background

Normally, when you run:

```bash
sleep 300
```

the terminal waits until the command finishes.

You can use `&` to run it in the background:

```bash
sleep 300 &
```

The `&` tells the shell to start the command as a **background job** and return control to the terminal immediately.

Example:

```text
[1] 12345
```

Here:

```text
1     → Job ID
12345 → PID
```

---

# 8. `jobs`

The `jobs` command displays background jobs started from the current shell.

```bash
jobs
```

Example:

```text
[1]+  Running    sleep 300 &
```

> **Important:** `jobs` shows jobs managed by the current shell. It does not list every process running on the system.

---

# 9. Find the `sleep` Process

Start a background process:

```bash
sleep 300 &
```

Then:

```bash
ps aux | grep sleep
```

You may see:

```text
ubuntu   12345  0.0  0.0  ... sleep 300
```

The number:

```text
12345
```

is the PID.

You can also use:

```bash
pgrep -a sleep
```

This is generally cleaner than using `ps | grep`.

---

# 10. Stop a Process Using `kill`

To terminate a process:

```bash
kill <PID>
```

Example:

```bash
kill 12345
```

By default, `kill` sends:

```text
SIGTERM (15)
```

---

# 11. SIGTERM

```text
SIGTERM = 15
```

SIGTERM means:

> **"Please terminate gracefully."**

It gives the application an opportunity to:

- Finish current operations
- Close files
- Release resources
- Save data
- Perform cleanup

This should normally be your **first choice** when stopping a process.

---

# 12. SIGKILL

```text
SIGKILL = 9
```

You can forcefully terminate a process using:

```bash
kill -9 <PID>
```

SIGKILL means:

> **"Terminate immediately."**

The process cannot catch or ignore `SIGKILL`, so it cannot perform normal cleanup.

### Use SIGKILL only when necessary.

For example:

```bash
kill 12345
```

Try graceful termination first.

If the process does not stop:

```bash
kill -9 12345
```

---

# 13. SIGHUP

```text
SIGHUP = 1
```

SIGHUP originally meant that a terminal/session was disconnected.

It is also commonly used by applications and services as a signal to **reload configuration**.

For example, some services support:

```bash
kill -HUP <PID>
```

to reload their configuration without completely restarting the process.

> **Important:** The exact behaviour of SIGHUP depends on how the application handles the signal. It does not universally mean "reload configuration."

---

# Signal Summary

| Signal | Number | Meaning | Typical Use |
|--------|--------|---------|-------------|
| `SIGHUP` | `1` | Hangup; often handled as a reload request | Reload configuration for supported applications |
| `SIGTERM` | `15` | Graceful termination request | Normal way to stop a process |
| `SIGKILL` | `9` | Immediate termination | Last resort when a process will not stop |

---

# Process Management Workflow

```text
Application is running
        │
        ▼
Find the process
        │
        ▼
ps / pgrep / top / htop
        │
        ▼
Get the PID
        │
        ▼
Send SIGTERM
        │
        ▼
Process stops?
     │       │
    Yes      No
     │       │
     ▼       ▼
   Done   Investigate
             │
             ▼
          SIGKILL
             │
             ▼
        Process stops
```

---

# Real-World DevOps Scenario

Suppose a server has very high CPU usage.

Start with:

```bash
top
```

or:

```bash
htop
```

Identify the process consuming the most CPU.

Then inspect it:

```bash
ps -p <PID> -f
```

You can also inspect all processes:

```bash
ps aux
```

If the process is stuck and needs to be stopped:

```bash
kill <PID>
```

If it does not terminate:

```bash
kill -9 <PID>
```

> **Best Practice:** Do not blindly kill high-CPU processes on production systems. First identify what the process is and whether stopping it could affect the application or service.

---

# Useful Commands

| Command | Purpose |
|---------|---------|
| `ps` | View processes associated with the current shell |
| `ps aux` | View processes across users in detailed format |
| `ps -ef` | View processes in UNIX-style format |
| `pgrep <name>` | Find processes by name |
| `pgrep -a <name>` | Find processes and show their command lines |
| `top` | Monitor processes in real time |
| `htop` | Interactive process monitoring |
| `jobs` | View background jobs of the current shell |
| `kill <PID>` | Send SIGTERM to a process |
| `kill -9 <PID>` | Send SIGKILL to a process |
| `ps -p <PID> -f` | Display detailed information about a specific process |

---

# Quick Revision

```text
Process
  → Running instance of a program

PID
  → Unique Process ID

ps
  → View processes

ps aux
  → View processes from all users

top
  → Real-time process monitoring

htop
  → Interactive alternative to top

&
  → Run a command in the background

jobs
  → View background jobs in the current shell

kill <PID>
  → Send SIGTERM for graceful termination

kill -9 <PID>
  → Send SIGKILL for forced termination

SIGHUP (1)
  → Hangup; often used by applications for reload

SIGTERM (15)
  → Graceful termination

SIGKILL (9)
  → Immediate termination
```

