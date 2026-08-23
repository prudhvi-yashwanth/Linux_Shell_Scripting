# Linux - Day 17: SSH, SSH Keys, and Secure Remote Access

## Overview

**SSH (Secure Shell)** is used to securely connect to and manage a remote Linux system over a network.

Example:

```bash
ssh ubuntu@192.168.1.50
```

SSH is commonly used by DevOps Engineers for:

- Connecting to Linux servers
- Managing cloud VMs
- Troubleshooting production systems
- Running remote commands
- Secure file transfers
- Server automation

---

# 1. How SSH Authentication Works

SSH commonly uses **public-key authentication**.

Two mathematically related keys are generated:

```text
Private Key
    │
    └── Stays on your machine
        Never share it

Public Key
    │
    └── Can be copied to servers
```

Example:

```text
Your Laptop
│
├── Private Key
│
└── Public Key
          │
          ▼
      Remote Server
      ~/.ssh/authorized_keys
```

When you connect:

```text
Client
  │
  │ Proves it owns the matching private key
  ▼
Server
  │
  │ Checks public key
  ▼
Authentication Successful
```

The private key is **not sent to the server**.

The server only needs your public key.

---

# 2. SSH Key Pair

A typical Ed25519 key pair is:

```text
~/.ssh/id_ed25519
```

Private key:

```text
~/.ssh/id_ed25519
```

Public key:

```text
~/.ssh/id_ed25519.pub
```

### Important

```text
Private key
→ Never share
→ Never upload to GitHub
→ Never paste into chat
→ Never copy unnecessarily to servers

Public key
→ Safe to share
→ Stored on the server
```

---

# 3. Generate an SSH Key Pair

Recommended command:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Options

| Option | Meaning |
|--------|---------|
| `-t ed25519` | Uses the Ed25519 key type |
| `-C` | Adds a comment to identify the key |

Ed25519 is a modern and efficient SSH key type and is generally preferred over older RSA configurations when supported.

---

# 4. Generate a Key Without a Comment

You can also run:

```bash
ssh-keygen -t ed25519
```

During the process, SSH asks:

```text
Enter file in which to save the key:
```

The default is usually:

```text
~/.ssh/id_ed25519
```

For a single main SSH key, the default location is usually fine.

---

# 5. Passphrase

SSH asks:

```text
Enter passphrase:
```

It is recommended to set a strong passphrase for the private key.

The passphrase protects the private key **at rest**.

For example:

```text
Laptop stolen
     │
     ▼
Attacker gets private key
     │
     ▼
Passphrase still required
```

Without the passphrase:

```text
Private key file
     │
     ▼
Potentially usable by attacker
```

> **Important:** A passphrase is not the same thing as the server login password. It protects your local private key.

---

# 6. SSH Key Files

After generating the key:

```bash
ls -la ~/.ssh/
```

You should see:

```text
id_ed25519
id_ed25519.pub
```

Check the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Do **not** use:

```bash
cat ~/.ssh/id_ed25519
```

and share the output.

That is the private key.

---

# 7. Copy the Public Key to the Server

The easiest way is:

```bash
ssh-copy-id username@server_ip
```

Example:

```bash
ssh-copy-id ubuntu@192.168.1.50
```

This adds your public key to:

```text
~/.ssh/authorized_keys
```

on the remote server.

---

# 8. Manual Method When `ssh-copy-id` Is Not Available

You can use:

```bash
cat ~/.ssh/id_ed25519.pub | ssh username@server_ip \
  "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Example:

```bash
cat ~/.ssh/id_ed25519.pub | ssh ubuntu@192.168.1.50 \
  "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

This:

1. Reads your public key.
2. Connects to the server.
3. Creates `~/.ssh` if required.
4. Appends the public key to `authorized_keys`.

---

# 9. Connect Using SSH

After the public key is installed:

```bash
ssh username@server_ip
```

Example:

```bash
ssh ubuntu@192.168.1.50
```

SSH will use the appropriate private key if it can find it through the default identity settings or SSH configuration.

If the private key is protected by a passphrase, SSH may ask for that passphrase.

---

# 10. SSH Configuration File

When managing multiple servers, remembering:

- Hostnames
- IP addresses
- Usernames
- Ports
- Identity files

becomes difficult.

The SSH configuration file solves this problem.

Create:

```bash
vim ~/.ssh/config
```

Example:

```sshconfig
Host devops-lab
    HostName 192.168.1.50
    User ubuntu
    Port 22
    IdentityFile ~/.ssh/id_ed25519

Host aws-prod
    HostName ec2-xx-xxx-xxx-xxx.compute.amazonaws.com
    User ec2-user
    Port 22
    IdentityFile ~/.ssh/aws-prod-key.pem
```

Now you can connect using:

```bash
ssh devops-lab
```

or:

```bash
ssh aws-prod
```

Instead of:

```bash
ssh -i ~/.ssh/aws-prod-key.pem ec2-user@ec2-xx-xxx-xxx-xxx.compute.amazonaws.com
```

---

# 11. Why `~/.ssh/config` Is Useful

Suppose you manage 10 servers.

Without SSH config:

```text
Different IPs
Different usernames
Different keys
Different ports
```

With SSH config:

```text
ssh dev
ssh staging
ssh prod
ssh database
```

It makes SSH access:

- Easier
- Cleaner
- Less error-prone
- Easier to maintain

---

# 12. `ssh-agent`

`ssh-agent` is a process that securely keeps decrypted private keys available in memory for the current session.

It helps you avoid entering the private-key passphrase repeatedly.

Start the agent:

```bash
eval "$(ssh-agent -s)"
```

Add your private key:

```bash
ssh-add ~/.ssh/id_ed25519
```

You enter the passphrase once.

After that, SSH can use the loaded key without repeatedly asking for the passphrase during that agent session.

---

# 13. Check Keys Loaded into `ssh-agent`

```bash
ssh-add -l
```

This lists the identities currently loaded into the agent.

To remove all keys from the agent:

```bash
ssh-add -D
```

---

# 14. macOS Keychain

On macOS, you can store the key in the Apple Keychain.

Use:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

You can also configure `~/.ssh/config`:

```sshconfig
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_ed25519
```

This can make SSH key usage more convenient across terminal sessions and reboots on macOS.

---

# 15. Server-Side SSH Configuration

On the server, SSH daemon configuration is usually stored in:

```text
/etc/ssh/sshd_config
```

Edit it carefully:

```bash
sudo vim /etc/ssh/sshd_config
```

Common security settings include:

```text
PubkeyAuthentication yes
PasswordAuthentication no
PermitRootLogin no
```

### Meaning

```text
PubkeyAuthentication yes
→ Allow SSH public-key authentication

PasswordAuthentication no
→ Disable password-based SSH authentication

PermitRootLogin no
→ Do not allow direct root SSH login
```

---

# 16. Important Production Safety Rule

Never disable password authentication before confirming that key-based authentication works.

Use this sequence:

```text
Existing SSH Session
        │
        ▼
Configure SSH Key
        │
        ▼
Open Second SSH Session
        │
        ▼
Test Key Authentication
        │
        ├── Failed → Fix Before Changing sshd_config
        │
        └── Successful
                │
                ▼
        Update sshd_config
                │
                ▼
        Validate Configuration
                │
                ▼
        Reload / Restart SSH
```

This prevents accidentally locking yourself out.

---

# 17. Validate SSH Configuration

Before restarting the SSH daemon, validate the configuration.

On many Linux systems:

```bash
sudo sshd -t
```

If there is no output, the configuration is generally valid.

Only after validation should you reload/restart SSH.

For systemd-based systems:

```bash
sudo systemctl reload ssh
```

or, if reload is not supported:

```bash
sudo systemctl restart ssh
```

The exact service name may be:

```text
ssh
```

or:

```text
sshd
```

depending on the distribution.

Check:

```bash
systemctl status ssh
```

---

# 18. SSH File Permissions

SSH is sensitive to incorrect permissions.

Typical permissions are:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Meaning

```text
~/.ssh
→ Owner only: read/write/execute

authorized_keys
→ Owner only: read/write

Private key
→ Owner only: read/write

Public key
→ Owner can read/write; others can read
```

> **Important:** Exact acceptable permissions can depend on SSH configuration and platform, but overly permissive private keys will normally be rejected for security reasons.

---

# 19. SSH Key Rotation

SSH keys should be rotated according to your organisation's security policy.

A fixed interval such as **90 to 180 days** may be appropriate in some environments, but there is no universal SSH requirement for this exact interval.

The important principle is:

> **Rotate keys without removing the currently working key until the new key has been tested.**

---

# 20. Safe SSH Key Rotation

## Step 1: Generate a New Key

Do not delete the old key yet.

```bash
ssh-keygen -t ed25519 \
  -f ~/.ssh/id_ed25519_new \
  -C "rotated $(date +%Y%m%d)"
```

This creates:

```text
~/.ssh/id_ed25519_new
~/.ssh/id_ed25519_new.pub
```

---

# Step 2: Add the New Public Key

Copy the new public key to the server:

```bash
ssh-copy-id \
  -i ~/.ssh/id_ed25519_new.pub \
  username@server_ip
```

The server now has both keys:

```text
authorized_keys
│
├── Old public key
└── New public key
```

---

# Step 3: Test the New Key

Open a **new SSH session**:

```bash
ssh -i ~/.ssh/id_ed25519_new username@server_ip
```

Confirm that authentication works.

Do not remove the old key yet.

---

# Step 4: Remove the Old Key

Only after the new key works, connect to the server:

```bash
ssh username@server_ip
```

Edit:

```bash
vim ~/.ssh/authorized_keys
```

Remove the old public key line.

Now:

```text
authorized_keys
│
└── New public key
```

---

# Step 5: Replace the Local Default Key

After confirming the new key is working:

```bash
mv ~/.ssh/id_ed25519_new ~/.ssh/id_ed25519
mv ~/.ssh/id_ed25519_new.pub ~/.ssh/id_ed25519.pub
```

Then fix permissions:

```bash
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

---

# 21. The Key Rotation Principle

Always maintain a working access path before removing the old one.

```text
Old Key Working
      │
      ▼
Generate New Key
      │
      ▼
Add New Public Key
      │
      ▼
Test New Key
      │
      ├── Failed → Keep Old Key
      │
      └── Successful
             │
             ▼
       Remove Old Key
             │
             ▼
       Replace Local Key
```

This avoids accidental lockouts.

---

# 22. Useful SSH Commands

```bash
# Generate Ed25519 key
ssh-keygen -t ed25519

# Copy public key to server
ssh-copy-id username@server_ip

# Connect to server
ssh username@server_ip

# Connect using a specific key
ssh -i ~/.ssh/id_ed25519 username@server_ip

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# List loaded keys
ssh-add -l

# Remove all keys from agent
ssh-add -D

# Validate sshd configuration
sudo sshd -t

# Check SSH service
sudo systemctl status ssh

# View SSH logs on systemd systems
sudo journalctl -u ssh
```

---

# 23. SSH Troubleshooting

Use verbose mode when SSH authentication fails:

```bash
ssh -v username@server_ip
```

For more detailed output:

```bash
ssh -vvv username@server_ip
```

This helps identify issues such as:

- Wrong username
- Wrong private key
- Permission problems
- Authentication method problems
- SSH configuration problems
- Network connectivity problems

---

# 24. Check Server's `authorized_keys`

On the server:

```bash
cat ~/.ssh/authorized_keys
```

Confirm that the correct public key exists.

Check permissions:

```bash
ls -ld ~/.ssh
ls -l ~/.ssh/authorized_keys
```

---

# 25. Check SSH Server Logs

Depending on the Linux distribution, SSH logs may be available through:

```bash
sudo journalctl -u ssh
```

or:

```bash
sudo journalctl -u sshd
```

For live logs:

```bash
sudo journalctl -u ssh -f
```

These logs can reveal authentication failures.

---

# 26. Common SSH Problems

| Problem | Things to Check |
|---------|-----------------|
| Permission denied | Username, key, `authorized_keys`, permissions |
| Connection timed out | Network, firewall, security groups, routing |
| Connection refused | SSH service, port, firewall |
| Wrong key | `IdentityFile`, `ssh-add`, `authorized_keys` |
| Key ignored | Private key permissions / server SSH configuration |
| Password rejected | PasswordAuthentication setting |
| Root login denied | `PermitRootLogin` |
| Cannot connect after config change | `sshd -t`, second SSH session, SSH logs |

---

# 27. DevOps Real-World Example

Suppose you manage:

```text
Development Server
Staging Server
Production Server
Database Server
```

You can define:

```sshconfig
Host dev
    HostName 10.0.0.10
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519

Host staging
    HostName 10.0.0.20
    User ubuntu
    IdentityFile ~/.ssh/id_ed25519

Host prod
    HostName 10.0.0.30
    User ubuntu
    IdentityFile ~/.ssh/prod-key

Host database
    HostName 10.0.0.40
    User dbadmin
    Port 2222
    IdentityFile ~/.ssh/db-key
```

Now:

```bash
ssh dev
ssh staging
ssh prod
ssh database
```

This is much easier than remembering every server's complete SSH command.

---

# 28. Security Best Practices

- Use Ed25519 keys where supported.
- Protect private keys with strong passphrases.
- Never share private keys.
- Never commit private keys to Git.
- Prefer key-based authentication over passwords for server access.
- Disable direct root SSH login where appropriate.
- Disable password authentication only after testing key access.
- Keep `authorized_keys` and private-key permissions restrictive.
- Rotate keys according to organisational policy.
- Remove old keys after verifying replacement access.
- Use `ssh-agent` or the platform keychain instead of repeatedly entering passphrases.
- Use network controls such as firewalls and security groups in addition to SSH authentication.

---

# Quick Revision

```text
SSH
→ Secure remote access

Private Key
→ Stays on your machine

Public Key
→ Stored on the server

authorized_keys
→ Contains allowed public keys

ssh-keygen
→ Generates SSH keys

ssh-copy-id
→ Copies public key to server

ssh
→ Connects to remote server

~/.ssh/config
→ Simplifies SSH connection configuration

ssh-agent
→ Keeps unlocked keys available in memory

sshd_config
→ SSH server configuration

sshd -t
→ Validate SSH server configuration

ssh -v
→ Troubleshoot SSH connection

Key Rotation
→ Add new key → Test → Remove old key
```

---

# Interview Answer

> **"SSH is used for secure remote access to Linux systems. With public-key authentication, I generate a private and public key pair. The private key stays on my machine, while the public key is added to the server's `~/.ssh/authorized_keys`. During authentication, the server verifies that I possess the matching private key without receiving the private key itself. For multiple servers, I use `~/.ssh/config` to define aliases, usernames, ports, and identity files. I also use `ssh-agent` to avoid entering the private-key passphrase repeatedly. On production servers, I prefer key-based authentication, disable direct root login, and disable password authentication only after verifying key-based access from a separate SSH session. During key rotation, I always add and test the new key before removing the old one."**
