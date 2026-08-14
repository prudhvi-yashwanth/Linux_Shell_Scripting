# Linux - Day 11: Arrays, Zombie Processes, Load Average, and OOM Killer

## Overview

Today we learned about:

- Bash arrays
- Looping through arrays
- Zombie processes
- Finding processes using `pgrep`
- Understanding Linux load average
- Checking CPU core count
- Linux Out Of Memory (OOM) Killer
- Checking memory and swap usage

---

# 1. Arrays in Bash

An **array** is used to store multiple values in a single variable.

Arrays are useful when a script needs to work with a list of values, such as:

- Server names
- File names
- Application names
- Environment names
- IP addresses

---

## Create an Array

```bash
array=("web01" "web02" "web03" "DB01" "DB02")
```

The array contains:

```text
web01
web02
web03
DB01
DB02
```

---

## Access Array Elements

Bash arrays use **zero-based indexing**.

That means the first element is at index `0`.

```bash
echo "${array[0]}"
echo "${array[1]}"
echo "${array[2]}"
```

Output:

```text
web01
web02
web03
```

---

# 2. Loop Through an Array

## Real-Time Scenario

Suppose a DevOps script needs to check the health of multiple servers.

Instead of writing the same command separately for every server, we can store the server names in an array and loop through them.

```bash
#!/bin/bash

array=("web01" "web02" "DB01" "MEM01")

for server in "${array[@]}"; do
    echo "Current server is $server"
done
```

Output:

```text
Current server is web01
Current server is web02
Current server is DB01
Current server is MEM01
```

---

## Why Use `"${array[@]}"`?

```bash
"${array[@]}"
```

Expands the array so that each element is treated as a separate value.

This is the recommended way to loop through Bash arrays.

Example:

```bash
for server in "${array[@]}"; do
    echo "$server"
done
```

---

# 3. Zombie Process

A **zombie process** is a process that has already finished execution, but its parent process has not yet collected its exit status.

The process is already dead, so it is not doing any work.

```text
Parent Process
      │
      ▼
Child Process
      │
      ▼
Child Finishes
      │
      ▼
Zombie Process
      │
      ▼
Parent reads exit status
      │
      ▼
Zombie is removed
```

---

## Important Points

A zombie process:

- Has already completed execution.
- Does not consume normal CPU or memory resources like a running process.
- Still has a process table entry containing its exit status.
- Exists until the parent process reaps it.

A small number of zombies is usually not a problem.

However, a large or continuously increasing number of zombies may indicate that the parent process is not correctly handling child processes.

---

# 4. Finding Zombie Processes

You can inspect processes and look for zombie state information:

```bash
ps aux | grep -i 'Z'
```

A more useful approach is:

```bash
ps -eo pid,ppid,stat,cmd | grep ' Z'
```

Here:

- `PID` → Process ID
- `PPID` → Parent Process ID
- `STAT` → Process state
- `Z` → Zombie state

You can also inspect a specific process:

```bash
ps -o pid,ppid,stat,cmd -p <PID>
```

---

# Important: Can You Kill a Zombie?

You cannot normally kill a zombie process because it has already finished.

For example:

```text
Zombie
  ↓
Already dead
```

Instead, investigate the **parent process**.

Find the parent PID:

```bash
ps -o pid,ppid,stat,cmd -p <PID>
```

Then investigate the parent:

```bash
ps -fp <PPID>
```

The parent process should normally read the child's exit status and remove the zombie entry.

---

# 5. `pgrep`

The `pgrep` command is used to find processes by name.

Example:

```bash
pgrep nginx
```

This returns the PID of matching Nginx processes.

Example:

```text
1234
1235
```

To display both the PID and command:

```bash
pgrep -a nginx
```

This is often cleaner than:

```bash
ps aux | grep nginx
```

---

# 6. Load Average

Linux **load average** shows the average amount of work waiting to be processed over time.

You can check it using:

```bash
uptime
```

Example:

```text
14:32:01 up 3 days,  load average: 0.52, 0.58, 0.61
```

The three values represent:

```text
0.52 → Last 1 minute
0.58 → Last 5 minutes
0.61 → Last 15 minutes
```

---

# 7. Why CPU Count Matters

Load average should not be interpreted without knowing how many CPU cores the system has.

Check the number of available processing units using:

```bash
nproc
```

Example:

```text
4
```

This means the system reports 4 logical CPUs.

---

## Understanding Load Average

Suppose:

```text
CPU cores = 4
Load average = 2.0
```

A load of `2.0` is generally below the system's processing capacity.

Suppose:

```text
CPU cores = 4
Load average = 8.0
```

This indicates a much higher level of system demand and may mean processes are waiting for CPU or other runnable/uninterruptible work.

> **Important:** Load average is not exactly the same as CPU utilisation. Linux load average also includes tasks in uninterruptible sleep, commonly associated with certain I/O waits.

---

# 8. Check Load Average

Use:

```bash
uptime
```

You can also use:

```bash
cat /proc/loadavg
```

Example:

```text
0.52 0.58 0.61 1/245 12345
```

The first three values are:

```text
1 minute
5 minutes
15 minutes
```

---

# 9. OOM Killer

**OOM** stands for **Out Of Memory**.

When the Linux system runs critically low on available memory, the kernel can invoke the **OOM Killer**.

Its job is to terminate one or more processes to free memory and protect the system from completely running out of memory.

```text
System memory becomes exhausted
            │
            ▼
        OOM Killer
            │
            ▼
 Selects a process
            │
            ▼
      Process killed
            │
            ▼
        Memory freed
```

---

# 10. Real-Time OOM Scenario

Suppose a production service suddenly stops.

The application's own logs show:

```text
No error
```

but the process has disappeared.

One possible reason is that the Linux kernel killed the process because the system ran out of memory.

This is why checking **kernel logs** is important.

---

# 11. Check for OOM Events

Using `dmesg`:

```bash
dmesg | grep -i "out of memory"
```

You can also search for:

```bash
dmesg | grep -i "oom"
```

On systems using systemd:

```bash
journalctl -k | grep -i "oom"
```

or:

```bash
journalctl -k | grep -i "out of memory"
```

### Explanation

```text
-k
```

shows kernel messages.

The OOM event is generated by the kernel, so the application's own logs may not contain the reason why the process was killed.

---

# 12. Check Memory Usage

Use:

```bash
free -h
```

The `-h` option displays values in a human-readable format.

Example:

```text
               total        used        free      shared  buff/cache   available
Mem:            7.7Gi       4.1Gi       1.0Gi       200Mi       2.6Gi       3.2Gi
Swap:           2.0Gi       100Mi       1.9Gi
```

---

# Important Memory Terms

| Term | Meaning |
|------|---------|
| `total` | Total physical memory |
| `used` | Memory currently used by processes and the system |
| `free` | Completely unused memory |
| `buff/cache` | Memory used for buffers and filesystem cache |
| `available` | Approximate memory available for new applications without swapping heavily |
| `Swap` | Disk-backed memory used when RAM is under pressure |

> **Important:** Do not judge memory pressure only by the `free` column. Linux uses unused RAM for caching, so the `available` value is usually more useful when checking whether the system has enough memory for new workloads.

---

# 13. Troubleshooting Flow

## High Load

```text
High Load Average
       │
       ▼
uptime
       │
       ▼
Check CPU count
       │
       ▼
nproc
       │
       ▼
Check running processes
       │
       ▼
top / htop
       │
       ▼
Identify CPU or I/O heavy process
```

---

## Service Suddenly Dies

```text
Service Stops
      │
      ▼
Check application logs
      │
      ▼
No useful error?
      │
      ▼
Check kernel logs
      │
      ▼
journalctl -k | grep -i oom
      │
      ▼
Check memory
      │
      ▼
free -h
```

---

## Growing Zombie Processes

```text
Zombie Count Increasing
        │
        ▼
Find Zombie PID
        │
        ▼
Find Parent PID (PPID)
        │
        ▼
Investigate Parent Process
        │
        ▼
Fix Parent Process
        │
        ▼
Parent Reaps Children
```

---

# Quick Revision

```text
Bash Array
  → Stores multiple values in one variable

"${array[@]}"
  → Expands each array element separately

ps
  → View processes

Zombie
  → Finished process waiting for its parent to collect its exit status

pgrep nginx
  → Find Nginx process IDs

uptime
  → Shows system uptime and 1/5/15 minute load average

nproc
  → Shows number of logical CPUs

OOM Killer
  → Kernel mechanism that kills processes when memory is critically exhausted

dmesg
  → View kernel messages

journalctl -k
  → View kernel logs from the systemd journal

free -h
  → Check memory and swap usage
```

---

# Interview Points

- A zombie process has completed execution but still has an entry in the process table because the parent has not collected its exit status.
- You normally investigate the **parent process**, not the zombie itself.
- `pgrep` is useful for finding process IDs by name.
- Load average represents system work over **1, 5, and 15 minutes**.
- Load average must be interpreted together with the number of CPU cores.
- A high load average does not always mean high CPU usage because Linux load also includes some tasks waiting on I/O.
- The OOM Killer is a kernel mechanism used when the system is under severe memory pressure.
- `journalctl -k` and `dmesg` are useful for finding kernel-level OOM events.
- `free -h` is useful for checking RAM and swap usage.
