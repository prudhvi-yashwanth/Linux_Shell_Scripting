# Linux Sudo Access

## What is Sudo Access?

`sudo` allows a regular Linux user to execute specific commands with elevated privileges, usually as `root`.

Users with sudo access:

- Are **not root users**.
- Remain regular users with their own UID and home directory.
- Can temporarily use elevated privileges according to the sudo rules assigned to them.

> Giving a user unrestricted sudo access is effectively giving that user root-level control.

---

# Full Sudo Access

On Ubuntu, adding a user to the `sudo` group generally gives them unrestricted sudo access.

Example:

    sudo usermod -aG sudo alice

Ubuntu commonly has this rule in `/etc/sudoers`:

    %sudo ALL=(ALL:ALL) ALL

You can check it with:

    sudo grep -E '^%sudo' /etc/sudoers

### Meaning of the Rule

    %sudo ALL=(ALL:ALL) ALL

- `%sudo` → Applies to all users in the `sudo` group.
- `ALL` → Applies to all hosts.
- `(ALL:ALL)` → Can run commands as any user and any group.
- `ALL` → Can run any command.

Therefore, a user in the `sudo` group can effectively perform root-level operations.

### Production Consideration

For a personal development VM, full sudo access may be acceptable.

In production, unrestricted sudo access may be excessive.

Follow the **Principle of Least Privilege**:

> Give users only the permissions they actually need.

---

# Limited / Granular Sudo Access

Instead of giving a user unrestricted sudo access, you can allow only specific commands.

Use `visudo` to safely edit sudo configuration.

Example:

    sudo visudo -f /etc/sudoers.d/bob-limited

`visudo` checks the sudoers syntax before saving the file, helping prevent configuration mistakes that could break sudo access.

A rule can look like:

    bob ALL=(ALL) /usr/bin/systemctl restart nginx

This allows `bob` to run only the specified command with sudo.

---

# `/etc/sudoers.d/`

Instead of modifying `/etc/sudoers` directly, custom rules should generally be placed under:

    /etc/sudoers.d/

Example:

    /etc/sudoers.d/bob-limited

The main `/etc/sudoers` configuration commonly includes this directory using an `@includedir` directive.

Files in `/etc/sudoers.d/` must follow the filename rules supported by `sudo`.

Commonly, files with names containing a `.` or ending in `~` are skipped.

Examples:

    /etc/sudoers.d/bob-limited        → Processed
    /etc/sudoers.d/bob-limited.txt    → Skipped
    /etc/sudoers.d/bob-limited.bak    → Skipped

> Always check the `@includedir /etc/sudoers.d` configuration and the `sudoers(5)` documentation for the exact filename rules on your system.

---

# Using Vim with `visudo`

By default, `visudo` may open the configuration using the system's configured editor.

To explicitly use Vim:

    sudo VISUAL=vim visudo -f /etc/sudoers.d/bob-limited

You can also set your preferred editor permanently.

For Bash:

    echo 'export EDITOR=vim' >> ~/.bashrc
    source ~/.bashrc

Then:

    sudo visudo -f /etc/sudoers.d/bob-limited

> `visudo` should be used instead of directly editing sudoers files because it validates the syntax before installing the changes.

---

# Sudoers Rule Syntax

Basic syntax:

    user host=(runas) command1, command2

Example:

    bob ALL=(ALL) /usr/bin/systemctl restart nginx

### Breakdown

| Part | Meaning |
|---|---|
| `bob` | User this rule applies to |
| `ALL` | Applies to all hosts |
| `(ALL)` | Command can be run as any user |
| `/usr/bin/systemctl restart nginx` | Specific command allowed |

---

# Example: Allow Specific Commands

Allow `bob` to start and check the status of Nginx:

    bob ALL=(ALL) /usr/bin/systemctl start nginx, /usr/bin/systemctl status nginx

Allow `bob` to restart Nginx:

    bob ALL=(ALL) /usr/bin/systemctl restart nginx

These rules restrict `bob` to the commands explicitly listed.

> Be careful with commands that can indirectly provide unrestricted root access. Some commands may allow users to execute other programs or modify privileged files.

---

# NOPASSWD

`NOPASSWD` allows a permitted command to run without prompting the user for their sudo password.

Example:

    deployer ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp

The `deployer` account can restart `myapp` without entering a password.

This can be useful for:

- CI/CD pipelines
- Deployment automation
- Service accounts

> Use `NOPASSWD` only for narrowly scoped commands. Avoid granting broad `NOPASSWD: ALL` permissions.

---

# Real-World Scenario

Suppose a server has three roles:

- `admin` → Full administrative access
- `oncall-engineer` → Can restart specific services and check their logs
- `deploy-bot` → Can restart one application without a password prompt

## Admin

    sudo usermod -aG sudo admin_username

This gives the user unrestricted sudo access on Ubuntu when the standard `sudo` group rule is present.

## On-Call Engineer

Create a dedicated sudoers file:

    sudo visudo -f /etc/sudoers.d/oncall

Add:

    oncall ALL=(ALL) /usr/bin/systemctl restart nginx, /usr/bin/systemctl restart myapp, /usr/bin/journalctl -u nginx, /usr/bin/journalctl -u myapp

Now `oncall` can run only the specified commands.

## Deployment Account

Create a dedicated sudoers file:

    sudo visudo -f /etc/sudoers.d/deploy-bot

Add:

    deploy-bot ALL=(ALL) NOPASSWD: /usr/bin/systemctl restart myapp

Now `deploy-bot` can restart only `myapp` without a password prompt.

---

# Check Sudo Permissions

To check what the current user can run:

    sudo -l

To check what another user is allowed to run:

    sudo -l -U username

Example:

    sudo -l -U bob

This helps verify the effective sudo permissions assigned to the user.

---

# Full vs Limited Sudo Access

| Access Type | Example | Permission |
|---|---|---|
| **Full Sudo** | `usermod -aG sudo user` | Effectively unrestricted root-level access |
| **Limited Sudo** | `/etc/sudoers.d/rulename` | Only specified commands |
| **NOPASSWD** | `NOPASSWD: /command` | Specified command does not prompt for sudo password |
| **Check Permissions** | `sudo -l` | Shows current user's sudo permissions |

## Quick Revision

    Full sudo
        ↓
    User added to sudo group
        ↓
    Effectively root-level access

    Limited sudo
        ↓
    /etc/sudoers.d/
        ↓
    Specific commands only

    NOPASSWD
        ↓
    Specific permitted command
        ↓
    No sudo password prompt

> **Important:** Always use the full executable path in sudoers rules and prefer narrowly scoped permissions.
