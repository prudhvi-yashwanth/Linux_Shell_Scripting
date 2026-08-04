# Linux - Day 4 (Bash Scripting Basics)

## Introduction to the Vim Editor

**Vim** is a powerful command-line text editor commonly used in Linux for creating and editing files, especially shell scripts and configuration files.

### Open a File

```bash
vim add.sh
```

If the file does not exist, Vim creates it.

---

## Basic Vim Modes

Vim works in different modes.

| Mode | Purpose |
|------|---------|
| Normal Mode | Default mode used for navigation and commands |
| Insert Mode | Used to type or edit text |
| Command Mode | Used to save, quit, search, and perform other operations |

### Useful Vim Shortcuts

| Shortcut | Description |
|----------|-------------|
| `i` | Enter Insert Mode |
| `Esc` | Return to Normal Mode |
| `:w` | Save the file |
| `:q` | Quit Vim |
| `:wq` | Save and quit |
| `:q!` | Quit without saving |
| `dd` | Delete the current line |
| `yy` | Copy (yank) the current line |
| `p` | Paste the copied line |
| `/text` | Search for text |
| `n` | Go to the next search result |
| `Shift + N` | Go to the previous search result |

---

# Shebang (`#!`)

Whenever you write a shell script, start it with a **Shebang**.

```bash
#!/bin/bash
```

### Why is it Required?

The Shebang tells Linux which interpreter should execute the script.

In this case:

```bash
#!/bin/bash
```

means:

> Execute this script using the Bash shell.

---

# Create and Run a Script

Create the script:

```bash
vim add.sh
```

Make it executable:

```bash
chmod +x add.sh
```

Run the script:

```bash
./add.sh
```

---

# Example 1: Addition Script

```bash
#!/bin/bash

echo "Enter first number:"
read num1

echo "Enter second number:"
read num2

sum=$((num1 + num2))

echo "Sum: $sum"
```

### Sample Output

```text
Enter first number:
10

Enter second number:
20

Sum: 30
```

---

# Line-by-Line Explanation

## Read User Input

```bash
read num1
```

Pauses the script and waits for the user to enter a value.

The entered value is stored in the variable `num1`.

---

## Read Another Value

```bash
read num2
```

Stores the second input in the variable `num2`.

---

## Perform Arithmetic

```bash
sum=$((num1 + num2))
```

`$(( ))` is called **Arithmetic Expansion**.

It allows Bash to perform mathematical calculations.

---

## Display the Result

```bash
echo "Sum: $sum"
```

Prints the calculated result.

---

# Important Syntax

| Syntax | Meaning |
|---------|---------|
| `read var` | Waits for user input and stores it in `var` |
| `$((expression))` | Performs arithmetic calculations |
| `$var` | Reads the value stored in a variable |

---

# Real-Time Scenario

Suppose you want your script to work in two ways:

- Accept values from the user interactively.
- Accept values directly from the command line.

For command-line inputs, Bash provides **Positional Parameters** such as `$1`, `$2`, `$3`, etc.

---

# Example 2: String Reversal

### Script

```bash
#!/bin/bash

# Run as:
# ./reverse.sh hello

str=$1

reversed=$(echo "$str" | rev)

echo "Original : $str"
echo "Reversed : $reversed"
```

---

## Run

```bash
./reverse.sh hello
```

Output:

```text
Original : hello
Reversed : olleh
```

---

# Explanation

## `$1`

```bash
str=$1
```

`$1` represents the first command-line argument.

Example:

```bash
./reverse.sh hello
```

Here,

```text
$1 = hello
```

---

## Command Substitution

```bash
$(command)
```

Runs a command and stores its output.

Example:

```bash
today=$(date)
```

The output of `date` is stored in the variable `today`.

---

## `rev` Command

```bash
echo "$str" | rev
```

The `rev` command reverses the characters in each line of input.

Example:

```text
hello
```

becomes

```text
olleh
```

---

# Example 3: Palindrome Check

A **Palindrome** is a word or sentence that reads the same forwards and backwards.

Examples:

```text
madam
level
radar
```

---

## Script

```bash
#!/bin/bash

str="madam"

[ "$str" == "$(echo "$str" | rev)" ] && echo "Palindrome" || echo "Not a Palindrome"
```

---

## Explanation

### Test Command

```bash
[ condition ]
```

Checks whether a condition is true.

---

### Logical AND (`&&`)

```bash
command1 && command2
```

If `command1` succeeds, `command2` is executed.

---

### Logical OR (`||`)

```bash
command1 || command2
```

If `command1` fails, `command2` is executed.

---

### Flow

```text
Original String
       │
       ▼
Reverse the String
       │
       ▼
Compare Both Strings
       │
       ├── Same → Palindrome
       │
       └── Different → Not a Palindrome
```

---

# Example 4: Count Words and Spaces

### Script

```bash
#!/bin/bash

# Run as:
# ./wordcount.sh "hello devops world"

sentence="$1"

word_count=$(echo "$sentence" | wc -w)

echo "Sentence   : $sentence"
echo "Word Count : $word_count"

# Count spaces

gap_count=$(echo "$sentence" | grep -o " " | wc -l)

echo "Gap Count  : $gap_count"
```

---

## Run

```bash
./wordcount.sh "hello devops world"
```

Output:

```text
Sentence   : hello devops world
Word Count : 3
Gap Count  : 2
```

---

# Explanation

## Count Words

```bash
wc -w
```

Counts the number of words in the input.

---

## Print Only Matching Text

```bash
grep -o " "
```

Options:

- `-o` → Prints only the matched text.

Since the pattern is a space (`" "`), each space is printed on a separate line.

---

## Count Spaces

```bash
grep -o " " | wc -l
```

First:

```bash
grep -o " "
```

prints each space on a separate line.

Then:

```bash
wc -l
```

counts those lines.

The result equals the number of spaces (gaps) in the sentence.

---

# Why Use Quotes Around `$1`?

Correct:

```bash
sentence="$1"
```

Run:

```bash
./wordcount.sh "hello devops world"
```

Here,

```text
$1 = "hello devops world"
```

The complete sentence is stored as one argument.

Without quotes:

```bash
./wordcount.sh hello devops world
```

Bash treats them as separate arguments:

```text
$1 = hello
$2 = devops
$3 = world
```

This can lead to incorrect results.

> **Best Practice:** Always quote variables (`"$variable"`) to safely handle values containing spaces or special characters.

---

# Summary

Today you learned:

- Basics of the Vim editor and commonly used shortcuts.
- The purpose of the Shebang (`#!/bin/bash`).
- How to create and execute Bash scripts.
- Reading user input using `read`.
- Performing arithmetic using `$(( ))`.
- Using positional parameters (`$1`, `$2`, etc.).
- Capturing command output using command substitution (`$( )`).
- Reversing a string using the `rev` command.
- Checking whether a string is a palindrome.
- Counting words using `wc -w`.
- Counting spaces using `grep -o` and `wc -l`.
- Why variables should be enclosed in double quotes.

---

# End of Day 4
