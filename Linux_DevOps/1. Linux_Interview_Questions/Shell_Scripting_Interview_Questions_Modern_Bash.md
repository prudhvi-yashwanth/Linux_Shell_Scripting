# Shell Scripting Interview Questions for DevOps Engineers (3+ YOE)

> From fundamentals to scenario-based scripting — the way it's actually asked in interviews.
> Each question includes: **Trigger Point**, **Script/Command**, and **Explanation**.

## Table of Contents
1. [Foundational Scripts](#foundational-scripts)
2. [Loops, Conditionals & Number Logic](#loops-conditionals--number-logic)
3. [String & Text Manipulation](#string--text-manipulation)
4. [Process & Log Handling Scripts](#process--log-handling-scripts)
5. [Core Shell Concepts](#core-shell-concepts)
6. [File & I/O Concepts](#file--io-concepts)
7. [Debugging & Best Practices](#debugging--best-practices)
8. [Scheduling & System Maintenance](#scheduling--system-maintenance)
9. [Commonly Used Shell Commands](#commonly-used-shell-commands)

---

## Foundational Scripts

Interviewers often start here to gauge basic syntax comfort before moving to scenarios. Don't skip these — fumbling on "add two numbers" after claiming 3 years of experience is a bad first impression.

### 1. Write a shell script to add two numbers.
**Trigger Point:** Warm-up question — tests basic syntax, variable handling, and arithmetic operators.
```bash
#!/bin/bash
read -p "Enter first number: " num1
read -p "Enter second number: " num2
sum=$((num1 + num2))
printf "Sum: %s\n" "$sum"
```
**Explanation:**
- `read -p` → prompts and reads input into a variable in one line.
- `$(( ))` → arithmetic expansion; bash's built-in way to do integer math (no need for `expr` in modern scripts).
- Alternative: `sum=$(expr $num1 + $num2)` — older syntax, slower (spawns a subprocess), avoid in new scripts.

**Follow-up interviewers ask:** "What if the input isn't a number?" → validate with a regex check:
```bash
if ! [[ "$num1" =~ ^[0-9]+$ ]]; then
  echo "Error: not a valid number"
  exit 1
fi
```

---

### 2. Write a script to check if a number is even or odd.
**Trigger Point:** Tests conditionals and the modulo operator.
```bash
#!/bin/bash
read -p "Enter a number: " num
if (( num % 2 == 0 )); then
  printf "%s is even\n" "$num"
else
  printf "%s is odd\n" "$num"
fi
```
**Explanation:**
- `(( ))` → arithmetic context; allows C-style comparison operators (`==`, `%`) without `$` prefixing inside.
- `%` → modulo operator.

---

### 3. Write a script to check if a file/directory exists.
**Trigger Point:** Extremely common building block for larger deployment scripts.
```bash
#!/bin/bash
FILE="/opt/app/config.yaml"
if [[ -f "$FILE" ]]; then
  printf "File exists\n"
elif [[ -d "$FILE" ]]; then
  printf "It's a directory, not a file\n"
else
  printf "Does not exist\n"
fi
```
**Explanation:**
- `-f` → true if regular file exists. `-d` → true if directory exists. `-e` → true if anything exists (file/dir/link).
- Always quote `"$FILE"` — unquoted variables break on filenames with spaces and cause word-splitting bugs.

---

### 4. Write a shell script to find the factorial of a number.
**Trigger Point:** Tests loop + accumulator pattern — a step up from simple arithmetic.
```bash
#!/bin/bash
read -p "Enter a number: " num
fact=1
for (( i=1; i<=num; i++ )); do
  fact=$(( fact * i ))
done
echo "Factorial of $num is $fact"
```
**Explanation:**
- C-style `for (( ))` loop — familiar syntax if coming from Python/Java background, commonly used for counted iteration.

---

## Loops, Conditionals & Number Logic

### 5. Write a shell script to print numbers divisible by 3 and 5 but not 15.
**Trigger Point:** Classic FizzBuzz-style variant — tests logical operators and loop control together.
```bash
#!/bin/bash
for (( i=1; i<=100; i++ )); do
  if { [ $(( i % 3 )) -eq 0 ] || [ $(( i % 5 )) -eq 0 ]; } && [ $(( i % 15 )) -ne 0 ]; then
    printf "%s\n" "$i"
  fi
done
```
**Explanation:**
- `$(( i % 3 ))` → modulo inside arithmetic expansion, then compared using `-eq`/`-ne` (numeric test operators).
- `{ ... }` groups the OR condition so it evaluates before the AND with the "not divisible by 15" check — without grouping, operator precedence would give the wrong result.
- `||` = logical OR, `&&` = logical AND (at the `[ ]` test level, not to be confused with `-o`/`-a` which are deprecated inside single `[ ]`).

---

### 6. Write a script to check if a number is prime.
**Trigger Point:** Common algorithmic scripting question to test loop + break logic together.
```bash
#!/bin/bash
read -p "Enter a number: " num
is_prime=1
if (( num < 2 )); then
  is_prime=0
else
  for (( i=2; i*i<=num; i++ )); do
    if (( num % i == 0 )); then
      is_prime=0
      break
    fi
  done
fi

if (( is_prime == 1 )); then
  echo "$num is prime"
else
  echo "$num is not prime"
fi
```
**Explanation:**
- `i*i<=num` → only need to check divisors up to the square root, avoiding unnecessary iterations.
- `break` → exits the loop immediately once a divisor is found — no need to keep checking.

---

### 7. What is the difference between `break` and `continue` statements in a loop?
**Trigger Point:** Conceptual question, usually asked right after a loop-based scripting question.
```bash
# break example
for i in 1 2 3 4 5; do
  if (( i == 3 )); then
    break
  fi
  printf "%s\n" "$i"
done
# Output: 1 2

# continue example
for i in 1 2 3 4 5; do
  if (( i == 3 )); then
    continue
  fi
  printf "%s\n" "$i"
done
# Output: 1 2 4 5
```
**Explanation:**
- `break` → exits the loop entirely, no further iterations run.
- `continue` → skips the rest of the current iteration only, loop continues with the next value.
- Both also accept a numeric argument (e.g., `break 2`) to break out of nested loops — a good detail to mention if asked a follow-up.

---

### 8. What are the different kinds of loops in shell scripting, and when do you use each?
**Trigger Point:** Conceptual — tests breadth of syntax knowledge.
```bash
# for loop — known list/range of items
for file in /var/log/*.log; do echo "$file"; done

# while loop — condition-based, unknown number of iterations
while read -r line; do echo "$line"; done < file.txt

# until loop — runs until condition becomes TRUE (opposite of while)
until systemctl is-active --quiet myapp; do
  echo "Waiting for service to start..."
  sleep 2
done
```
**Explanation:**
- `for` → best for iterating over a known list (files, array, range of numbers).
- `while` → best for reading input line-by-line or looping while a condition holds true (e.g., polling).
- `until` → less commonly used, but ideal for "wait until X becomes true" patterns like health checks — a good one to bring up to show depth.

---

## String & Text Manipulation

### 9. Write a script to print the number of occurrences of 's' in "Mississippi".
**Trigger Point:** Tests string manipulation approaches — interviewers often want to see multiple methods.
```bash
#!/bin/bash
str="Mississippi"
char="s"

# Method 1: using grep -o
count=$(echo "$str" | grep -o "$char" | wc -l)
echo "Count using grep: $count"

# Method 2: using parameter expansion (pure bash, no subprocess)
temp="${str//[^$char]/}"
echo "Count using parameter expansion: ${#temp}"

# Method 3: character-by-character loop
count2=0
for (( i=0; i<${#str}; i++ )); do
  if [[ "${str:$i:1}" == "$char" ]]; then
    ((count2++))
  fi
done
echo "Count using loop: $count2"
```
**Explanation:**
- `grep -o` → prints only the matched part of each line (one match per line), so piping to `wc -l` counts occurrences.
- `${str//[^$char]/}` → parameter expansion that removes every character that is NOT `s`, leaving only the `s` characters behind; `${#temp}` then gives its length — the fastest method since it avoids spawning subprocesses.
- `${str:$i:1}` → substring extraction: starting at index `$i`, length `1` (bash string indexing is 0-based).
- Mentioning multiple approaches (especially the subprocess-free one) signals stronger scripting maturity.

---

### 10. Write a script to check if a string is a palindrome.
**Trigger Point:** Common string-logic question.
```bash
#!/bin/bash
read -p "Enter a string: " str
reversed=$(echo "$str" | rev)
if [[ "$str" == "$reversed" ]]; then
  printf "Palindrome\n"
else
  printf "Not a palindrome\n"
fi
```
**Explanation:**
- `rev` → reverses characters of each input line — simplest and most idiomatic way to reverse a string in bash without writing a manual loop.

---

### 11. How do you sort a list of names in a file?
**Trigger Point:** Very common — direct from the list; tests `sort` flags fluency.
```bash
sort names.txt
sort -r names.txt          # reverse order
sort -u names.txt          # sort + remove duplicates
sort -f names.txt          # case-insensitive sort
sort -k2 employees.txt     # sort by 2nd column
sort -n numbers.txt        # numeric sort (not lexicographic)
```
**Explanation:**
- `-r` → reverse (descending).
- `-u` → unique, removes duplicate lines after sorting.
- `-f` → fold case (case-insensitive).
- `-k2` → sort using the 2nd field/column as key (fields split by whitespace by default; use `-t','` to set a custom delimiter like CSV).
- `-n` → numeric sort — critical distinction: without `-n`, `sort` treats "10" as coming before "9" (lexicographic/string comparison).

---

### 12. Write a script to count word frequency in a text file.
**Trigger Point:** Common text-processing scenario, reuses the "sort | uniq -c" pattern from Linux commands.
```bash
#!/bin/bash
tr -s ' ' '\n' < file.txt | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -rn | head -10
```
**Explanation:**
- `tr -s ' ' '\n'` → squeezes (`-s`) repeated spaces and translates spaces into newlines, putting one word per line.
- `tr '[:upper:]' '[:lower:]'` → normalizes case so "The" and "the" count as the same word.
- Then the familiar `sort | uniq -c | sort -rn` frequency-count pipeline.

---

## Process & Log Handling Scripts

### 13. Write a simple shell script to list all processes.
**Trigger Point:** Directly from the list — tests basic process introspection scripting.
```bash
#!/bin/bash
printf "%-6s %-6s %s\n" "PID" "PPID" "CMD"
ps -eo pid,ppid,cmd --sort=-pid
```
**Explanation:**
- `-e` → select every process, `-o` → custom output format (columns), `--sort=-pid` → sort descending by PID.
- A more scenario-driven version: script that lists only processes above a memory/CPU threshold:
```bash
#!/bin/bash
THRESHOLD=50
ps -eo pid,comm,%mem --sort=-%mem | awk -v t="$THRESHOLD" 'NR==1 || $3+0 > t'
```
This filters and prints only processes consuming more than `THRESHOLD`% memory — a good way to show you can go beyond the literal question.

---

### 14. Write a script to print only errors from a remote log.
**Trigger Point:** Directly from the list — tests SSH scripting + remote log filtering, a real day-to-day DevOps task.
```bash
#!/bin/bash
REMOTE_USER="devops"
REMOTE_HOST="10.0.1.15"
LOG_PATH="/var/log/app/app.log"

ssh "$REMOTE_USER@$REMOTE_HOST" "grep -i 'error' $LOG_PATH"

# Real-time streaming version:
ssh "$REMOTE_USER@$REMOTE_HOST" "tail -f $LOG_PATH" | grep --line-buffered -i "error"
```
**Explanation:**
- `ssh user@host "command"` → executes the command on the remote server and streams output back to the local terminal.
- `grep -i` → case-insensitive match (catches "Error", "ERROR", "error").
- `--line-buffered` → needed when piping a continuous stream (`tail -f`) through `grep`, otherwise output gets buffered and doesn't appear in real time.
- **Production note (good to mention):** for repeated use, set up SSH key-based auth to avoid password prompts inside scripts, and consider `ssh -o BatchMode=yes` so the script fails fast instead of hanging if a key isn't set up.

---

### 15. How will you manage logs of a system that generates huge log files every day?
**Trigger Point:** Directly from the list — this is a conceptual + scripting hybrid question about log rotation strategy.
```bash
# Example logrotate config: /etc/logrotate.d/myapp
/var/log/myapp/*.log {
    daily
    rotate 14
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
}
```
```bash
# Manual cleanup script alternative (if logrotate isn't available/used)
#!/bin/bash
LOG_DIR="/var/log/myapp"
find "$LOG_DIR" -name "*.log" -mtime +14 -exec gzip {} \;
find "$LOG_DIR" -name "*.gz" -mtime +30 -delete
```
**Explanation:**
- **`logrotate`** (the standard production answer) → `daily` = rotate once a day, `rotate 14` = keep 14 old copies, `compress` = gzip old logs, `delaycompress` = don't compress the most recent rotated log (in case a process is still writing to it), `missingok` = don't error if the log is missing, `notifempty` = don't rotate if empty, `copytruncate` = copies the log then truncates the original in place — important for apps that keep a file handle open and don't support re-opening log files on signal.
- Mention alternatives depending on scale: shipping logs off-box entirely (to CloudWatch, ELK/EFK stack, Loki) so local disk never fills up in the first place — this is usually the answer that impresses interviewers most, since it shows systems thinking beyond a single script.

---

## Core Shell Concepts

### 16. List the most commonly used shell commands.
**Trigger Point:** Directly from the list — usually the opening question to gauge day-to-day command fluency.

| Category | Commands |
|---|---|
| Navigation | `pwd`, `cd`, `ls -la` |
| File ops | `cp`, `mv`, `rm -rf`, `touch`, `mkdir -p` |
| Viewing | `cat`, `less`, `head`, `tail -f` |
| Searching | `grep`, `find`, `locate` |
| Text processing | `awk`, `sed`, `cut`, `sort`, `uniq`, `tr`, `wc` |
| Permissions | `chmod`, `chown`, `chgrp` |
| Process | `ps`, `top`, `htop`, `kill`, `nohup` |
| Networking | `curl`, `wget`, `ss`, `ping`, `scp`, `rsync` |
| Disk | `df -h`, `du -sh`, `mount` |
| Archiving | `tar`, `gzip`, `zip` |
| System | `uptime`, `uname -a`, `systemctl`, `journalctl` |
| Scripting utils | `xargs`, `tee`, `read`, `echo`, `printf` |

**Explanation:** Don't just recite the list — pick 2-3 and explain a real use case for each (e.g., "`xargs` — I use it to pipe a list of stale docker image IDs into `docker rmi`"). Shows applied experience, not memorization.

---

### 17. Is bash dynamically or statically typed?
**Trigger Point:** Directly from the list — a language-fundamentals conceptual question.
```bash
x=10          # x is a string "10" here
x=hello       # perfectly valid — no type error
echo $((x + 5))   # fails only if used in arithmetic context and isn't numeric
```
**Explanation:**
- Bash is **dynamically typed**, and further, **all variables are stored as strings by default** — there's no `int`, `string`, `bool` declaration. Type only matters when a variable is used in a specific context (e.g., arithmetic `(( ))`, where a non-numeric string causes an error).
- You *can* declare type hints using `declare -i` (integer) or `declare -r` (readonly), but these are optional constraints, not real static typing — bash won't stop you from reassigning a non-integer to a `declare -i` variable in every case, it just tries to evaluate it arithmetically.

---

### 18. What are the disadvantages of shell scripting?
**Trigger Point:** Directly from the list — a maturity/judgment question; interviewers want to see you know when NOT to use bash.
**Explanation (talking points):**
- **Poor error handling by default** — a script continues even after a command fails, unless you explicitly use `set -e`.
- **Weak data structures** — no real support for nested objects/dictionaries; arrays are limited compared to Python's lists/dicts.
- **Fragile string-based typing** — no type safety, easy to introduce subtle bugs (word-splitting, unquoted variables).
- **Not ideal for complex logic** — anything beyond simple orchestration/glue-code becomes hard to read and maintain; better suited for a real language (Python/Go) once logic grows (API calls, JSON parsing, complex branching).
- **Portability issues** — scripts written for `bash` may break on `sh`/`dash` (e.g., default shell on Debian), and behavior can vary slightly across bash versions.
- **Debugging is harder** at scale — no real IDE-level debugging, mostly `set -x` and print statements.

Good answer structure: acknowledge the weaknesses, then state your real practice — "I use bash for orchestration/glue tasks (file ops, service restarts, CI/CD steps) and switch to Python once there's real logic, JSON parsing, or API interaction involved."

---

## File & I/O Concepts

### 19. How do you open a file in read-only mode?
**Trigger Point:** Directly from the list — tests understanding of file descriptors and redirection, not just editor commands.
```bash
# Viewing a file read-only (editor level)
view file.txt          # vim's read-only mode
vim -R file.txt         # same, explicit flag
less file.txt           # inherently read-only viewer

# Opening a file descriptor in read-only mode (scripting level)
exec 3< file.txt
read -r line <&3
exec 3<&-               # close the file descriptor
```
**Explanation:**
- `vim -R` → `-R` flag opens vim in read-only mode, preventing accidental writes.
- `exec 3< file.txt` → opens the file on file descriptor 3, using `<` (read redirection) — useful in scripts that need to read from a file across multiple commands without repeatedly opening/closing it.
- `3<&-` → closes file descriptor 3 explicitly, good practice to avoid descriptor leaks in long-running scripts.

---

### 20. What is the difference between soft links and hard links?
**Trigger Point:** Directly from the list — a very common conceptual filesystem question.
```bash
ln -s /path/to/original.txt symlink.txt     # soft/symbolic link
ln /path/to/original.txt hardlink.txt       # hard link

ls -li original.txt symlink.txt hardlink.txt
```
**Explanation:**
- **Soft (symbolic) link**: a pointer/shortcut to the file's *path*. Has its own inode number. Breaks ("dangling link") if the original file is deleted or moved. Can link across filesystems/partitions. Shown with an `l` in `ls -l` output and an arrow (`symlink.txt -> original.txt`).
- **Hard link**: a second directory entry pointing to the *same inode* as the original. Shares the same inode number (`ls -li` confirms this). Data isn't deleted until **all** hard links to it are removed. Cannot span across filesystems/partitions, and cannot link to a directory.
- Real-world relevance: this is exactly why `lsof`/`fuser` can find "deleted but still open" files — the inode (data) persists as long as any link (including an open file descriptor, in effect) still references it.

---

## Debugging & Best Practices

### 21. How will you debug a shell script?
**Trigger Point:** Directly from the list — one of the most important practical questions; separates real practitioners from memorizers.
```bash
bash -x script.sh              # trace every command as it executes
bash -n script.sh              # syntax check only, don't execute
set -x                         # enable trace mode mid-script
set +x                         # disable trace mode
set -euo pipefail              # fail-fast mode (see below)
```
**Explanation:**
- `-x` → prints each command (with variable values substituted) before executing it, prefixed with `+` — the single most useful debugging tool for shell scripts.
- `-n` → parses the script for syntax errors without running it (a quick sanity check before deploying).
- `set -e` → exits immediately if any command returns non-zero (fails fast instead of silently continuing with a broken state).
- `set -u` → treats use of an unset variable as an error (catches typos in variable names).
- `set -o pipefail` → makes a pipeline (`cmd1 | cmd2`) return failure if *any* command in the pipe fails, not just the last one — without this, `false | true` returns 0 (success), hiding real failures.
- `set -euo pipefail` at the top of every production script is considered a strong best-practice signal in interviews — mention it proactively.

---

### 22. What is the difference between `$@` and `$*`, and how do you handle script arguments properly?
**Trigger Point:** Common follow-up when discussing script robustness.
```bash
#!/bin/bash
echo "Number of args: $#"
echo "All args (\$@): $@"
echo "Script name: $0"
echo "First arg: $1"

for arg in "$@"; do
  echo "Arg: $arg"
done
```
**Explanation:**
- `$#` → number of arguments passed. `$0` → script name itself. `$1`, `$2`... → positional arguments.
- `"$@"` → expands each argument as a **separate** quoted word — preserves arguments containing spaces correctly. This is almost always what you want.
- `"$*"` → expands all arguments as a **single** string joined by the first character of `IFS` (space by default) — rarely what you want in a loop, since it merges everything into one word.
- Getting this distinction right (and always quoting `"$@"`) is a strong signal of scripting maturity.

---

### 23. How do you use `getopts` to handle command-line flags in a script?
**Trigger Point:** Tests whether you write scripts meant to be reused by others, not just one-off personal scripts.
```bash
#!/bin/bash
while getopts "u:p:h" opt; do
  case $opt in
    u) USER="$OPTARG" ;;
    p) PORT="$OPTARG" ;;
    h) echo "Usage: $0 -u <user> -p <port>"; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG"; exit 1 ;;
  esac
done

echo "User: $USER, Port: $PORT"
# Usage: ./script.sh -u admin -p 8080
```
**Explanation:**
- `getopts "u:p:h"` → defines valid flags; a `:` after a letter means it expects a value (e.g., `-u admin`), no `:` means it's a boolean flag (like `-h`).
- `$OPTARG` → holds the value passed to a flag that expects one.
- `\?)` → catches any invalid/unrecognized flag.
- Mentioned in the Linux commands guide too — this pattern is reused constantly in production automation scripts (backup scripts, deployment scripts) to make them configurable instead of hardcoded.

---

## Scheduling & System Maintenance

### 24. What is crontab in Linux, and can you provide example usage?
**Trigger Point:** Directly from the list.
```bash
crontab -l                  # list current user's cron jobs
crontab -e                  # edit current user's cron jobs
crontab -u username -l      # list another user's cron jobs (needs privilege)

# Example: run a backup script every day at 2:30 AM
30 2 * * * /opt/scripts/backup.sh >> /var/log/backup.log 2>&1
```
**Explanation:**
- `crontab` → manages scheduled recurring jobs per user, read by the `cron` daemon.
- Field order: `minute hour day-of-month month day-of-week command`.
- `>> /var/log/backup.log 2>&1` → appends both stdout and stderr to a log file — essential in production cron entries since cron's default behavior (mailing output to the user) is usually not monitored and failures go unnoticed otherwise.
- System-wide cron jobs (not tied to a specific user) live in `/etc/crontab` or `/etc/cron.d/`.

---

### 25. Write a script to monitor disk usage and send an alert if it crosses a threshold.
**Trigger Point:** A very common "write me something real" scenario question — combines scripting + monitoring logic.
```bash
#!/bin/bash
set -euo pipefail

THRESHOLD=80
ALERT_EMAIL="devops-team@company.com"

usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')

if (( usage > THRESHOLD )); then
  echo "ALERT: Disk usage is at ${usage}% on $(hostname) at $(date)" | \
    mail -s "Disk Space Alert" "$ALERT_EMAIL"
  echo "Alert sent — usage at ${usage}%"
else
  echo "Disk usage normal: ${usage}%"
fi
```
**Explanation:**
- `df -h / | awk 'NR==2 {print $5}'` → `NR==2` selects the second line (skipping the header), `$5` grabs the "Use%" column.
- `tr -d '%'` → strips the `%` sign so the value can be used in numeric comparison.
- `mail -s` → sends an email alert (requires `mailutils`/`mailx` configured); in real infra this is more commonly wired to Slack/PagerDuty via a webhook `curl` call instead — a good thing to mention as the "production" version:
```bash
curl -X POST -H 'Content-type: application/json' \
  --data "{\"text\":\"Disk usage alert: ${usage}% on $(hostname)\"}" \
  "$SLACK_WEBHOOK_URL"
```
- This question is often a springboard to ask about turning it into a cron job (ties back to Q24) — mention scheduling it via `crontab -e` to run every 15 minutes.

---

### 26. Write a script to check if a given service is running, and restart it if it's down.
**Trigger Point:** A classic self-healing automation scenario, tests `systemctl` + conditional scripting together.
```bash
#!/bin/bash
SERVICE="nginx"

if systemctl is-active --quiet "$SERVICE"; then
  echo "$SERVICE is running"
else
  echo "$SERVICE is down. Restarting..."
  systemctl restart "$SERVICE"
  sleep 2
  if systemctl is-active --quiet "$SERVICE"; then
    echo "$SERVICE restarted successfully"
  else
    echo "Failed to restart $SERVICE. Manual intervention needed."
    exit 1
  fi
fi
```
**Explanation:**
- `systemctl is-active --quiet` → returns exit code 0 if active, non-zero otherwise, `--quiet` suppresses text output so it can be used purely for its exit status in an `if` check.
- Double-checking after the restart (rather than assuming success) shows defensive scripting — a detail interviewers specifically look for at the 3+ years level.
- Natural follow-up: "how would you avoid a restart loop if it keeps failing?" → mention tracking a retry counter or falling back to alerting instead of retrying indefinitely.

---

## Networking Troubleshooting (Conceptual)

### 27. What are the networking troubleshooting tools that you use?
**Trigger Point:** Directly from the list — conceptual, but expect a follow-up asking you to actually use one live.

| Tool | Purpose |
|---|---|
| `ping` | Basic reachability + latency check |
| `traceroute` / `mtr` | Trace the network path / hop-by-hop latency & loss |
| `curl -v` / `wget` | Test HTTP(S) endpoints, view headers, response codes |
| `ss` / `netstat` | Check listening ports and active connections |
| `dig` / `nslookup` | DNS resolution troubleshooting |
| `telnet <host> <port>` | Test raw TCP port connectivity |
| `tcpdump` | Packet-level capture and inspection |
| `nc` (netcat) | Test port connectivity, quick data transfer, banner grabbing |

**Explanation:** State your actual troubleshooting *order*, not just a list — e.g.: "First `ping` for basic reachability, then `telnet`/`nc` to confirm the specific port is open, then `curl -v` if it's an HTTP service to check the actual response, and `dig` if I suspect it's a DNS issue rather than a connectivity one." A structured answer here matters more than the tool list itself.

---

## Quick Reference: Script Skeleton Interviewers Like to See

```bash
#!/bin/bash
set -euo pipefail    # fail-fast: exit on error, undefined var, or failed pipe

LOG_FILE="/var/log/myscript.log"
log() { echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"; }

trap 'log "Script failed at line $LINENO"' ERR

log "Script started"
# ... actual logic here ...
log "Script completed successfully"
```
**Why this matters:** Using this skeleton (or parts of it) unprompted in a live-coding round signals production-grade habits: fail-fast behavior, timestamped logging, and a `trap` on `ERR` to capture exactly where a script broke — exactly the kind of detail that separates "I can write a script" from "I write scripts that survive production."

---

*Compiled for DevOps/SRE/Platform Engineer interview prep — 3+ years experience level. Pairs with the Linux Scenario-Based Interview Questions README.*