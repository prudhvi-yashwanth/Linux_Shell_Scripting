# Linux Shell Scripting - `if/else` Conditions

## Overview

In Bash scripting, `if`, `elif`, and `else` are used to make decisions based on conditions.

For example, a script can check whether:

- A number is greater than 10
- A number is equal to 10
- A number is less than 10
- A string is empty
- Two strings are equal
- A required variable is set

---

# Basic `if/elif/else` Syntax

```bash
if [ condition ]; then
    # commands
elif [ another_condition ]; then
    # commands
else
    # commands
fi
```

### Important

- `if` → Starts the condition.
- `elif` → Checks another condition if the previous condition is false.
- `else` → Runs when none of the conditions are true.
- `fi` → Ends the `if` statement.

---

# Example: Compare a Number

```bash
#!/bin/bash

num="$1"

if [ "$num" -gt 10 ]; then
    echo "$num is greater than 10"
elif [ "$num" -eq 10 ]; then
    echo "$num is equal to 10"
else
    echo "$num is less than 10"
fi
```

Run the script:

```bash
chmod +x compare.sh
./compare.sh 15
```

Output:

```text
15 is greater than 10
```

Another example:

```bash
./compare.sh 10
```

Output:

```text
10 is equal to 10
```

And:

```bash
./compare.sh 5
```

Output:

```text
5 is less than 10
```

---

# Numeric Comparison Operators

Bash uses specific operators for numeric comparisons.

| Operator | Meaning | Example |
|----------|---------|---------|
| `-gt` | Greater than | `[ "$a" -gt "$b" ]` |
| `-lt` | Less than | `[ "$a" -lt "$b" ]` |
| `-eq` | Equal to | `[ "$a" -eq "$b" ]` |
| `-ge` | Greater than or equal to | `[ "$a" -ge "$b" ]` |
| `-le` | Less than or equal to | `[ "$a" -le "$b" ]` |
| `-ne` | Not equal to | `[ "$a" -ne "$b" ]` |

### Example

```bash
a=20
b=10

if [ "$a" -gt "$b" ]; then
    echo "a is greater than b"
fi
```

Output:

```text
a is greater than b
```

---

# String Comparison

For strings, you can use:

## Check if Strings are Equal

```bash
if [ "$str1" == "$str2" ]; then
    echo "Strings are equal"
fi
```

---

## Check if Strings are Not Equal

```bash
if [ "$str1" != "$str2" ]; then
    echo "Strings are different"
fi
```

> **Best Practice:** Always quote variables when comparing strings:
>
> ```bash
> [ "$str1" == "$str2" ]
> ```
>
> This prevents problems when a variable contains spaces or is empty.

---

# Check if a String is Empty

```bash
if [ -z "$str1" ]; then
    echo "String is empty"
fi
```

The `-z` operator checks whether the string has **zero length**.

Example:

```bash
str1=""

if [ -z "$str1" ]; then
    echo "String is empty"
fi
```

Output:

```text
String is empty
```

---

# Check Whether a Required Variable is Set

This is a common pattern in DevOps scripts.

```bash
if [ -z "$deploy_env" ]; then
    echo "Error: deploy_env is not set"
    exit 1
fi
```

### Explanation

```bash
[ -z "$deploy_env" ]
```

Checks whether `deploy_env` is empty.

If it is empty:

```bash
echo "Error: deploy_env is not set"
```

prints an error message.

Then:

```bash
exit 1
```

stops the script and returns an exit status of `1`.

---

# Exit Status

Every Linux command returns an **exit status**.

Generally:

```text
0     → Success
Non-0 → Failure or another condition
```

You can check the exit status of the **most recently executed command** using:

```bash
echo $?
```

### Example

```bash
ls /tmp
echo $?
```

If the command succeeds:

```text
0
```

If a command fails:

```bash
ls /does-not-exist
echo $?
```

You may get a non-zero value such as:

```text
2
```

The exact non-zero value depends on the command.

---

# Why Exit Codes Matter in DevOps

Exit codes are heavily used in:

- Shell scripts
- CI/CD pipelines
- Docker
- Kubernetes
- Monitoring
- Automation

For example:

```bash
./deploy.sh

if [ $? -eq 0 ]; then
    echo "Deployment successful"
else
    echo "Deployment failed"
fi
```

A better Bash pattern is to test the command directly:

```bash
if ./deploy.sh; then
    echo "Deployment successful"
else
    echo "Deployment failed"
fi
```

This avoids accidentally changing `$?` before checking it.

---

# Important Syntax Rule

There must be spaces around the brackets:

Correct:

```bash
if [ "$num" -gt 10 ]; then
```

Incorrect:

```bash
if ["$num" -gt 10]; then
```

The `[` is actually a Bash command (`test`), so the spaces are important.

---

# Quick Revision

```text
if       → Check a condition
elif     → Check another condition
else     → Run when all conditions are false
fi       → End the if statement

-gt      → Greater than
-lt      → Less than
-eq      → Equal to
-ge      → Greater than or equal to
-le      → Less than or equal to
-ne      → Not equal to

For string operations and comparisons
==       → String equality
!=       → String inequality
-z       → String is empty

$?       → Exit status of the previous command
0        → Usually means success
non-zero → Usually means failure
```
