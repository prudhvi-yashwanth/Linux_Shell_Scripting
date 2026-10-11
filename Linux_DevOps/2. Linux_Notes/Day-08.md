# Bash Scripting - Day 8

## `for` and `while` Loops

Loops are used in Bash scripting when we need to execute the same block of commands multiple times.

The two commonly used loops are:

- `for` loop
- `while` loop

---

# 1. `for` Loop

A `for` loop is generally used when we want to iterate over a known list or collection of items.

The number of iterations may be known in advance, but it does not have to be. The important point is that a `for` loop processes each item in a given list.

---

## Basic Syntax

```bash
for variable in list; do
    commands
done
```

---

## Example 1: Loop Through Numbers

```bash
for i in 1 2 3 4 5; do
    echo "Number: $i"
done
```

Output:

```text
Number: 1
Number: 2
Number: 3
Number: 4
Number: 5
```

The loop runs once for each item in the list.

---

# 2. Brace Expansion

Instead of writing all the numbers manually, we can use brace expansion.

```bash
for i in {1..5}; do
    echo "Number: $i"
done
```

Output:

```text
Number: 1
Number: 2
Number: 3
Number: 4
Number: 5
```

### `{1..5}`

```bash
{1..5}
```

is expanded by Bash into:

```text
1 2 3 4 5
```

Example:

```bash
echo {1..5}
```

Output:

```text
1 2 3 4 5
```

---

# 3. Loop Through Files

A `for` loop is very useful in DevOps scripts when working with multiple files.

```bash
for file in *.sh; do
    echo "Processing: $file"
done
```

The `*.sh` pattern matches shell scripts in the current directory.

For example, if the directory contains:

```text
deploy.sh
backup.sh
test.sh
```

the loop processes each file.

Output:

```text
Processing: deploy.sh
Processing: backup.sh
Processing: test.sh
```

### Important

`*.sh` uses **pathname expansion (globbing)**.

It is not technically the same as a regular expression.

---

# 4. `chmod +x`

If you want to execute a shell script directly:

```bash
chmod +x script.sh
```

Then run:

```bash
./script.sh
```

The `+x` adds execute permission.

---

# 5. `while` Loop

A `while` loop repeatedly executes commands **as long as a condition is true**.

Unlike a `for` loop, a `while` loop is commonly used when the number of iterations is not known in advance.

The loop stops when its condition becomes false.

---

## Basic Syntax

```bash
while [ condition ]; do
    commands
done
```

---

# 6. Example: Count from 1 to 5

```bash
count=1

while [ "$count" -le 5 ]; do
    echo "Count: $count"
    count=$((count + 1))
done
```

Output:

```text
Count: 1
Count: 2
Count: 3
Count: 4
Count: 5
```

### How It Works

Initially:

```text
count = 1
```

The condition is:

```bash
[ "$count" -le 5 ]
```

As long as `count` is less than or equal to `5`, the loop continues.

After every iteration:

```bash
count=$((count + 1))
```

increases the value by `1`.

When:

```text
count = 6
```

the condition:

```text
6 <= 5
```

is false, so the loop stops.

---

# 7. Real-Time DevOps Scenario

Suppose a service is not running yet.

Instead of checking it only once, we can repeatedly check the service status until:

- The service starts successfully, or
- The maximum number of attempts is reached.

This is a common pattern in DevOps automation.

---

# Service Health Check Script

```bash
#!/bin/bash

serviceName="$1"
attempts=0
max_attempts=5

if [ -z "$serviceName" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi

while ! systemctl is-active --quiet "$serviceName"; do
    attempts=$((attempts + 1))

    echo "Waiting for $serviceName to start... attempt $attempts"

    if [ "$attempts" -ge "$max_attempts" ]; then
        echo "Error: $serviceName failed to start after $max_attempts attempts"
        exit 1
    fi

    sleep 2
done

echo "$serviceName is up!"
```

---

# Run the Script

First, make it executable:

```bash
chmod +x service-check.sh
```

Run it by passing the service name:

```bash
./service-check.sh nginx
```

---

# Script Explanation

## Read the Service Name

```bash
serviceName="$1"
```

`$1` represents the first command-line argument.

Example:

```bash
./service-check.sh nginx
```

Then:

```text
$1 = nginx
```

---

## Initialise the Attempt Counter

```bash
attempts=0
```

Keeps track of how many times we have checked the service.

---

## Set Maximum Attempts

```bash
max_attempts=5
```

The script will check the service a maximum of 5 times.

---

## Validate the Input

```bash
if [ -z "$serviceName" ]; then
    echo "Usage: $0 <service-name>"
    exit 1
fi
```

The `-z` operator checks whether the string is empty.

If the user runs:

```bash
./service-check.sh
```

the script displays:

```text
Usage: ./service-check.sh <service-name>
```

and exits.

---

# Check the Service Status

```bash
systemctl is-active --quiet "$serviceName"
```

Checks whether the service is active.

The `--quiet` option suppresses normal output and relies on the command's exit status.

The command returns:

```text
0     → Service is active
non-0 → Service is not active
```

---

# Negating the Condition

```bash
while ! systemctl is-active --quiet "$serviceName"; do
```

The `!` reverses the command's exit status.

Therefore, the loop continues while the service is **not active**.

```text
Service active?
      │
      ├── Yes → Stop loop
      │
      └── No → Continue checking
```

---

# Increase the Attempt Counter

```bash
attempts=$((attempts + 1))
```

Increases the counter by one after every failed check.

---

# Check Maximum Attempts

```bash
if [ "$attempts" -ge "$max_attempts" ]; then
```

Checks whether the number of attempts is greater than or equal to the maximum allowed attempts.

If:

```text
attempts = 5
max_attempts = 5
```

then:

```text
5 >= 5
```

is true.

The script exits with:

```bash
exit 1
```

---

# Wait Before Trying Again

```bash
sleep 2
```

Waits for 2 seconds before checking the service again.

This prevents the script from continuously checking the service without any delay.

---

# Successful Completion

When the service becomes active, the `while` condition becomes false.

The loop stops and the script executes:

```bash
echo "$serviceName is up!"
```

Output:

```text
nginx is up!
```

---

# `for` vs `while`

| `for` Loop | `while` Loop |
|------------|--------------|
| Iterates over a list or collection | Runs while a condition remains true |
| Commonly used when processing known items | Commonly used when the stopping point depends on a condition |
| Useful for files, arguments, ranges, etc. | Useful for retries, polling, health checks, etc. |
| Example: process every `.log` file | Example: wait for a service to become active |

---

# Common `for` Syntax

```bash
for var in list; do
    commands
done
```

**Meaning:**

Loops through each item in a list.

---

# Brace Expansion

```bash
{1..5}
```

Generates:

```text
1 2 3 4 5
```

Example:

```bash
for i in {1..5}; do
    echo "$i"
done
```

---

# Wildcard Expansion

```bash
for file in *.sh; do
    echo "$file"
done
```

The `*.sh` pattern matches shell script files in the current directory.

This is very common in operations and automation scripts.

---

# `$@`, `"$@"`, and `$#`

These are important when working with command-line arguments.

Suppose we run:

```bash
./script.sh one "two three" four
```

The script receives three arguments.

```text
$1 = one
$2 = two three
$3 = four
```

---

## `$#`

```bash
$#
```

Represents the **number of positional arguments** passed to the script.

Example:

```bash
echo "$#"
```

Output:

```text
3
```

---

## `$@`

```bash
$@
```

Represents all positional arguments.

However, when used **unquoted**, the arguments can be split further based on shell word splitting.

Example:

```bash
for arg in $@; do
    echo "$arg"
done
```

This can cause problems when an argument contains spaces.

---

## `"$@"`

```bash
"$@"
```

Represents all positional arguments while preserving each argument as a separate item.

This is the recommended form when passing all script arguments to another command or function.

Example:

```bash
for arg in "$@"; do
    echo "$arg"
done
```

For:

```bash
./script.sh one "two three" four
```

Output:

```text
one
two three
four
```

---

# `$@` vs `"$@"` vs `$#`

| Syntax | Meaning |
|--------|---------|
| `$@` | All positional arguments, subject to word splitting when unquoted |
| `"$@"` | All positional arguments, preserving each argument separately |
| `$#` | Number of positional arguments |

> **Best Practice:** Prefer `"$@"` when you need to pass all arguments while preserving spaces and argument boundaries.

---

# Execution Flow of the Service Check

```text
Start Script
     │
     ▼
Read Service Name
     │
     ▼
Is Service Name Empty?
     │
     ├── Yes → Show Usage → exit 1
     │
     └── No
          │
          ▼
    Check Service
          │
          ▼
    Is Service Active?
       │          │
      Yes         No
       │          │
       ▼          ▼
  Exit Loop   Increase Attempt
                    │
                    ▼
             Maximum Attempts?
                │        │
               Yes       No
                │         │
                ▼         ▼
             exit 1    sleep 2
                          │
                          └──────► Check Again
```

---

# DevOps Use Cases

Loops are commonly used in DevOps scripts for:

- Checking service status
- Waiting for application startup
- Polling an API
- Checking whether a deployment is ready
- Processing multiple files
- Processing multiple servers
- Running health checks
- Retrying failed operations
- Processing command-line arguments

---

# Summary

Today you learned:

- How `for` loops work.
- How `while` loops work.
- How to iterate over a fixed list.
- How to use `{1..5}` for ranges.
- How to process files using `*.sh`.
- How to make scripts executable using `chmod +x`.
- How to use `while` for retry and polling logic.
- How to check a Linux service using `systemctl`.
- How to use `sleep` between retries.
- How to use `$1` for command-line arguments.
- The difference between `$@`, `"$@"`, and `$#`.
