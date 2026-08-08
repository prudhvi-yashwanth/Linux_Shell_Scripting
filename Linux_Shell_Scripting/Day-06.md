# Linux - `chmod` vs `chown`, Groups, `id`, and `journalctl`

## `chmod` vs `chown` - The Actual Difference

A simple way to remember the difference is:

> **`chmod` = What can be done?**  
> **`chown` = Who owns it?**

| Command | Stands For | Controls | Example |
|---------|------------|----------|---------|
| `chmod` | Change Mode | What actions are allowed: read, write, execute | `chmod 755 file` |
| `chown` | Change Owner | Who owns the file: user and group | `chown alice:developers file` |

---

# `chmod`

The `chmod` command changes the **permissions** of a file or directory.

Permissions control whether a user can:

- Read (`r`)
- Write (`w`)
- Execute (`x`)

### Example

```bash
chmod 755 script.sh
```

This gives:

```text
Owner  → read + write + execute
Group  → read + execute
Others → read + execute
```

---

# `chown`

The `chown` command changes the **ownership** of a file or directory.

### Syntax

```bash
chown user:group file
```

### Example

```bash
sudo chown alice:developers file
```

This changes:

```text
Owner → alice
Group → developers
```

---

# `groups` and `id`

The `groups` and `id` commands help you understand a user's:

- User ID (UID)
- Primary Group ID (GID)
- Supplementary groups
- Group memberships

---

## `groups`

```bash
groups
```

Displays the groups that the current user belongs to.

Example:

```text
alice : alice developers docker
```

You can also check another user:

```bash
groups alice
```

---

## `id`

```bash
id
```

Displays detailed identity information for the current user.

Example:

```text
uid=1000(alice) gid=1000(alice) groups=1000(alice),1001(developers),998(docker)
```

### Important Information

- `uid` → User ID
- `gid` → Primary Group ID
- `groups` → Supplementary groups

---

# `journalctl`

`journalctl` reads logs from the **systemd journal**.

It is commonly used to troubleshoot services managed by `systemctl`.

Instead of manually searching through different files under `/var/log`, `journalctl` provides a central place to view systemd-related logs.

---

## View All Logs

```bash
journalctl
```

Displays the journal logs, oldest first.

> **Note:** This can produce a very large amount of output. It is usually better to filter the logs.

---

## View Recent Logs

```bash
journalctl -xe
```

Options:

- `-x` → Adds explanatory information where available.
- `-e` → Jumps to the end of the journal (most recent entries).

---

## View Logs for a Specific Service

```bash
journalctl -u nginx
```

The `-u` option filters logs for a specific systemd service.

---

## Follow Service Logs in Real Time

```bash
journalctl -u nginx -f
```

The `-f` option follows new log entries as they are generated.

Press:

```text
Ctrl + C
```

to stop following the logs.

---

## View Logs from the Last Hour

```bash
journalctl --since "1 hour ago"
```

Displays logs generated during the last hour.

---

## Show Only Errors

```bash
journalctl -p err
```

The `-p` option filters logs based on priority.

`err` means **error-level logs**.

---

# Real-Time Troubleshooting Scenario

Suppose Nginx fails to start.

First, try starting the service:

```bash
sudo systemctl start nginx
```

If it fails, immediately check the service logs:

```bash
journalctl -u nginx -xe
```

This can help identify the reason for the failure.

You can also check the service status:

```bash
sudo systemctl status nginx
```

A common troubleshooting flow is:

```text
Service fails
     │
     ▼
systemctl status nginx
     │
     ▼
journalctl -u nginx -xe
     │
     ▼
Identify the error
     │
     ▼
Fix the configuration/problem
     │
     ▼
Restart the service
```

---

# Real-Time Scenario: Fix Group Access

Suppose `alice` needs write access to:

```text
/var/www/app
```

and the `deployers` group should manage the application files.

### Step 1: Add Alice to the Group

```bash
sudo usermod -aG deployers alice
```

The `-aG` options mean:

- `-a` → Append to existing supplementary groups
- `-G` → Specify supplementary groups

---

### Step 2: Change the Directory Group

```bash
sudo chown -R :deployers /var/www/app
```

This changes the group ownership to:

```text
deployers
```

without changing the existing owner.

---

### Step 3: Give the Group Write Access

```bash
sudo chmod -R 775 /var/www/app
```

This gives:

```text
Owner  → rwx
Group  → rwx
Others → r-x
```

---

### Complete Flow

```text
Add Alice to deployers
        │
        ▼
usermod -aG deployers alice
        │
        ▼
Change directory group
        │
        ▼
chown -R :deployers /var/www/app
        │
        ▼
Give group write permission
        │
        ▼
chmod -R 775 /var/www/app
```

> **Note:** Alice may need to log out and log back in for the new group membership to appear in a new login session. `newgrp deployers` can also start a shell with the updated group as the effective group.

---

# Quick Self-Test

## Question 1

You want to add a user to the `docker` group. Which command should you use?

### Answer

```bash
sudo usermod -aG docker alice
```

---

## Question 2

A file or directory is owned by `root`, and you need to change its ownership to `alice`. Which command should you use?

### Answer

For a single file:

```bash
sudo chown alice file
```

For a directory and everything inside it:

```bash
sudo chown -R alice /var/www/app
```

> **Note:** If you also want to change the group, use:
>
> ```bash
> sudo chown -R alice:alice /var/www/app
> ```

---

## Question 3

A shell script is not executable. Which command should you use?

### Answer

```bash
chmod +x /var/www/app/script.sh
```

---

# Quick Revision

```text
chmod → What can the user do?
chown → Who owns the file?
groups → Which groups does the user belong to?
id     → What are the user's UID, GID, and groups?
journalctl → View systemd journal logs
```

---

# Summary

Today you learned:

- Difference between `chmod` and `chown`
- Linux file ownership and permissions
- User and group information using `groups` and `id`
- Viewing systemd logs using `journalctl`
- Filtering logs by service, time, and priority
- Troubleshooting services using `systemctl` and `journalctl`
- Adding users to groups using `usermod -aG`
- Changing group ownership using `chown`
- Giving group permissions using `chmod`
- Common Linux permission troubleshooting scenarios

---

# End of Notes
