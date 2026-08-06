# Linux Shell Scripting

## Functions and `case` Statement

As shell scripts become larger, writing all commands in a single block makes them difficult to maintain.

To write clean and reusable scripts, Bash provides:

- Functions
- Positional arguments
- `shift`
- `case` statements

These features help build scripts similar to real-world command-line tools.

---

# Example: Toolkit Script

```bash
#!/bin/bash

# Run as:
# ./toolkit.sh <operation> <arguments>

# Examples:
# ./toolkit.sh add 5 3
# ./toolkit.sh subtract 10 4
# ./toolkit.sh reverse hello
# ./toolkit.sh wordcount "hello devops world"

add() {
    echo "Sum: $(( $1 + $2 ))"
}

subtract() {
    echo "Result: $(( $1 - $2 ))"
}

reverse() {
    echo "Reversed: $(echo "$1" | rev)"
}

wordcount() {
    echo "Words: $(echo "$1" | wc -w)"
}

operation=$1

# Remove the first argument
shift

case "$operation" in
    add)
        add "$1" "$2"
        ;;
    subtract)
        subtract "$1" "$2"
        ;;
    reverse)
        reverse "$1"
        ;;
    wordcount)
        wordcount "$1"
        ;;
    *)
        echo "Unknown operation: $operation"
        echo "Usage: ./toolkit.sh {add|subtract|reverse|wordcount} <arguments>"
        ;;
esac
```

---

# Make the Script Executable

```bash
chmod +x toolkit.sh
```

Run the script:

```bash
./toolkit.sh add 5 3
```

Output:

```text
Sum: 8
```

---

# Function in Bash

A function is a reusable block of commands.

### Syntax

```bash
function_name() {
    commands
}
```

or

```bash
function function_name {
    commands
}
```

---

## Example

```bash
add() {
    echo "Sum: $(( $1 + $2 ))"
}
```

Whenever the function is called,

```bash
add 5 3
```

Output:

```text
Sum: 8
```

### Why Use Functions?

Functions help to:

- Avoid duplicate code
- Improve readability
- Make scripts easier to maintain
- Reuse the same logic multiple times

---

# Positional Parameters

When a script is executed, the command-line arguments are stored in positional parameters.

Example:

```bash
./toolkit.sh add 5 3
```

| Parameter | Value |
|-----------|-------|
| `$0` | `toolkit.sh` |
| `$1` | `add` |
| `$2` | `5` |
| `$3` | `3` |

---

# Store the Operation

```bash
operation=$1
```

Stores the first argument in the variable `operation`.

Example:

```bash
operation="add"
```

---

# `shift` Command

```bash
shift
```

The `shift` command removes the first positional argument and shifts all remaining arguments one position to the left.

### Before `shift`

| Parameter | Value |
|-----------|-------|
| `$1` | `add` |
| `$2` | `5` |
| `$3` | `3` |

---

### After `shift`

| Parameter | Value |
|-----------|-------|
| `$1` | `5` |
| `$2` | `3` |

This makes it easier to process the remaining arguments without worrying about the operation name.

---

# `case` Statement

A `case` statement is used when one variable can have multiple possible values.

It is cleaner and easier to read than a long `if...elif...else` chain.

### Syntax

```bash
case "$variable" in
    value1)
        commands
        ;;
    value2)
        commands
        ;;
    *)
        default commands
        ;;
esac
```

---

# Example

```bash
case "$operation" in
    add)
        add "$1" "$2"
        ;;
    subtract)
        subtract "$1" "$2"
        ;;
    reverse)
        reverse "$1"
        ;;
    wordcount)
        wordcount "$1"
        ;;
esac
```

If the user runs:

```bash
./toolkit.sh reverse hello
```

Then:

```text
operation = reverse
```

The `reverse()` function is called.

Output:

```text
Reversed: olleh
```

---

# Default Case (`*`)

```bash
*)
    echo "Unknown operation"
    ;;
```

The `*` acts as the **default case**.

It executes when none of the specified options match.

Example:

```bash
./toolkit.sh multiply 5 2
```

Output:

```text
Unknown operation: multiply
Usage: ./toolkit.sh {add|subtract|reverse|wordcount} <arguments>
```

---

# Real-Time Scenario

Suppose you are building an internal DevOps utility script.

Instead of creating separate scripts like:

```text
add.sh
subtract.sh
reverse.sh
wordcount.sh
```

You can create a single script:

```text
toolkit.sh
```

and execute different operations:

```bash
./toolkit.sh add 10 20
./toolkit.sh subtract 50 15
./toolkit.sh reverse devops
./toolkit.sh wordcount "hello devops world"
```

This approach is:

- Easier to maintain
- More scalable
- Similar to how many Linux command-line tools work

---

# Execution Flow

```text
User Executes Script
        │
        ▼
./toolkit.sh add 5 3
        │
        ▼
operation = add
        │
        ▼
shift
        │
        ▼
$1 = 5
$2 = 3
        │
        ▼
case Statement
        │
        ▼
Calls add()
        │
        ▼
Prints:
Sum: 8
```

---

# Key Concepts

| Syntax | Description |
|---------|-------------|
| `function_name() { }` | Defines a function |
| `$1`, `$2`, `$3` | Positional arguments |
| `$0` | Script name |
| `shift` | Removes the first positional argument and shifts the remaining arguments left |
| `case ... esac` | Multi-way branching based on a variable's value |
| `*` | Default case in a `case` statement |

---

# Interview Tips

- Use **functions** to avoid repeating code and improve maintainability.
- Use **`case` statements** when checking a single variable against multiple fixed values.
- Use **`shift`** when you want to process the remaining command-line arguments after handling the first one.
- Use **positional parameters** (`$1`, `$2`, etc.) to pass inputs to shell scripts.
- Always include a **default (`*`) case** to handle invalid or unexpected user input.

---

# Summary

Today you learned:

- How to define and use functions in Bash.
- How positional parameters work.
- The purpose of the `shift` command.
- How to use the `case` statement for multi-way branching.
- How to handle invalid inputs using the default (`*`) case.
- How to build a reusable command-line toolkit using a single shell script.

---

# End of Notes

