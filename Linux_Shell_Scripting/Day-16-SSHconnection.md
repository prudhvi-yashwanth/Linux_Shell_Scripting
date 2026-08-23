## SSH (Secure Shell)

SSH (**Secure Shell**) is used to securely connect to and manage a remote machine.

It commonly uses **public-key authentication**, where two mathematically related keys are used:

- **Private key** → Stays on your machine. Never share it.
- **Public key** → Can be shared and is stored on the remote server.

The private key is **never sent to the server**.

The basic authentication flow is:

```text
Your Machine
    │
    │ SSH connection
    ▼
Remote Server
    │
    │ Cryptographic challenge
    ▼
Your Machine
    │
    │ Proves it has the matching private key
    ▼
Remote Server
    │
    ▼
Authentication Successful
```

The server stores your public key and verifies that the client has the corresponding private key.

---

## SSH Key Pair

The default Ed25519 key pair is:

```bash
~/.ssh/id_ed25519
```

This is the **private key**.

```bash
~/.ssh/id_ed25519.pub
```

This is the **public key**.

Remember:

```text
id_ed25519
→ PRIVATE KEY
→ Never share

id_ed25519.pub
→ PUBLIC KEY
→ Safe to share
```

---

## Generate an SSH Key

Use:

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Options

```text
-t ed25519
→ Specifies the Ed25519 key type.

-C "comment"
→ Adds a label to the key.
```

The comment is only for identification and does not affect the cryptographic security of the key.

> **Correction:** The command is `ssh-keygen`, not `ssh-keygen` with a missing `k`.

You can also simply run:

```bash
ssh-keygen -t ed25519
```

---

## Where to Save the Key

When prompted:

```text
Enter file in which to save the key:
```

The default is:

```text
~/.ssh/id_ed25519
```

For a normal setup, the default location is fine.

If you manage multiple servers or environments, separate keys can be used:

```text
~/.ssh/id_ed25519
~/.ssh/aws-prod-key
~/.ssh/dev-key
```

---

## Passphrase

When `ssh-keygen` asks for a passphrase, it is recommended to set one.

The passphrase protects the private key if someone gets access to the key file.

```text
Private Key
      │
      ▼
Protected with passphrase
```

Without the passphrase, a stolen encrypted private key is much harder to use.

---

## Copy the Public Key to the Server

The easiest method is:

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

## Manual Public Key Copy

If `ssh-copy-id` is not available:

```bash
cat ~/.ssh/id_ed25519.pub | ssh username@server_ip \
"mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

This:

1. Reads your public key.
2. Connects to the remote server.
3. Creates the `.ssh` directory if it does not exist.
4. Appends the public key to `authorized_keys`.

---

## Connect to the Server

Once the public key has been added:

```bash
ssh username@server_ip
```

Example:

```bash
ssh ubuntu@192.168.1.50
```

If your private key has a passphrase, SSH may ask for that passphrase.

Using `ssh-agent` can avoid repeated passphrase prompts.

---

## Connect Using a Specific Private Key

When you have multiple keys:

```bash
ssh -i ~/.ssh/aws-prod-key.pem ec2-user@server_ip
```

The `-i` option specifies the private key.

Example:

```bash
ssh -i ~/.ssh/aws-prod-key.pem ec2-user@54.123.45.67
```

---

## SSH Config

When managing multiple servers, use:

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

Now you can simply use:

```bash
ssh devops-lab
```

or:

```bash
ssh aws-prod
```

instead of typing the complete connection details every time.

---

## Real-Time Scenario

Suppose you manage 10 servers with different:

- IP addresses
- Usernames
- Ports
- Private keys

Without SSH config, you need to remember all of them.

With:

```text
~/.ssh/config
```

you can create short names:

```bash
ssh dev
ssh staging
ssh aws-prod
ssh db-prod
```

This makes SSH access easier and reduces configuration mistakes.

---

## SSH Agent

`ssh-agent` stores unlocked private keys in memory so SSH does not ask for the key passphrase every time.

Start the agent:

```bash
eval "$(ssh-agent -s)"
```

Add your key:

```bash
ssh-add ~/.ssh/id_ed25519
```

You enter the passphrase once.

After that, during the agent's lifetime:

```text
ssh command
    │
    ▼
ssh-agent
    │
    ▼
Unlocked private key
    │
    ▼
Server authentication
```

> **Correction:** The correct command is `ssh-agent`, not `ssh-agnet`.

---

## Check Keys Loaded in SSH Agent

```bash
ssh-add -l
```

This shows the keys currently loaded in the agent.

Remove all loaded keys:

```bash
ssh-add -D
```

---

## macOS Keychain

On macOS, the private-key passphrase can be stored in the Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

You can also add the following to:

```text
~/.ssh/config
```

```sshconfig
Host *
    UseKeychain yes
    AddKeysToAgent yes
```

Then:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

This can reduce repeated passphrase prompts across sessions.

---

## Server-Side SSH Configuration

On the Linux server, the SSH daemon configuration is commonly located at:

```bash
sudo vim /etc/ssh/sshd_config
```

Common security settings are:

```text
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
```

### Meaning

```text
PasswordAuthentication no
→ Disable password-based SSH authentication.

PubkeyAuthentication yes
→ Allow public-key authentication.

PermitRootLogin no
→ Do not allow direct SSH login as root.
```

These settings should be used according to the server's access requirements and organisational security policy.

---

## Important: Do Not Lock Yourself Out

Before changing:

```bash
/etc/ssh/sshd_config
```

make sure key-based access is already working.

Recommended process:

```text
Current SSH Session
       │
       ▼
Open Second SSH Session
       │
       ▼
Test Key-Based Login
       │
       ▼
Login Successful
       │
       ▼
Modify sshd_config
       │
       ▼
Validate Configuration
       │
       ▼
Restart SSH
       │
       ▼
Test New Connection Again
```

Do not close your original working session until the new configuration is confirmed.

---

## Validate SSH Configuration

Before restarting the SSH service:

```bash
sudo sshd -t
```

If there is no output, the configuration syntax is normally valid.

Then restart the SSH service.

Depending on the Linux distribution:

```bash
sudo systemctl restart ssh
```

or:

```bash
sudo systemctl restart sshd
```

Check the service:

```bash
sudo systemctl status ssh
```

or:

```bash
sudo systemctl status sshd
```

---

## SSH File Permissions

Correct permissions are important for SSH key authentication.

### `.ssh` Directory

```bash
chmod 700 ~/.ssh
```

### `authorized_keys`

```bash
chmod 600 ~/.ssh/authorized_keys
```

### Private Key

```bash
chmod 600 ~/.ssh/id_ed25519
```

### Public Key

```bash
chmod 644 ~/.ssh/id_ed25519.pub
```

Recommended:

```text
~/.ssh/
    │
    ├── 700  directory
    ├── 600  id_ed25519
    ├── 644  id_ed25519.pub
    └── 600  authorized_keys
```

---

## SSH Key Rotation

SSH keys should be rotated according to your organisation's security policy.

Do not treat:

```text
90 days
180 days
```

as universal requirements.

The rotation period depends on:

- Security policy
- Compliance requirements
- Risk level
- Environment
- Type of access

The most important principle is:

> **Always add and test the new key before removing the old key.**

---

## Safe SSH Key Rotation

### Step 1 - Generate a New Key

Do not delete the old key.

```bash
ssh-keygen -t ed25519 \
  -f ~/.ssh/id_ed25519_new \
  -C "rotated-$(date +%Y%m%d)"
```

This creates:

```text
~/.ssh/id_ed25519_new
~/.ssh/id_ed25519_new.pub
```

The comment contains the rotation date.

---

## Step 2 - Add the New Public Key

Copy the new public key to the server:

```bash
ssh-copy-id \
  -i ~/.ssh/id_ed25519_new.pub \
  username@server_ip
```

The server now has:

```text
Old Public Key
New Public Key
```

Both can be used temporarily.

---

## Step 3 - Test the New Key

Open a fresh SSH session:

```bash
ssh -i ~/.ssh/id_ed25519_new username@server_ip
```

Confirm that login works successfully.

Do not remove the old key until this test passes.

---

## Step 4 - Remove the Old Public Key

After confirming the new key works:

```bash
ssh username@server_ip
```

Edit:

```bash
nano ~/.ssh/authorized_keys
```

Remove only the old public-key entry.

Keep the new key.

---

## Step 5 - Replace the Local Key

After confirming everything is working:

```bash
mv ~/.ssh/id_ed25519_new ~/.ssh/id_ed25519
mv ~/.ssh/id_ed25519_new.pub ~/.ssh/id_ed25519.pub
```

Then verify:

```bash
ssh username@server_ip
```

---

## Key Rotation Principle

Always follow:

```text
Generate New Key
      │
      ▼
Add New Public Key
      │
      ▼
Test New Key
      │
      ▼
Confirm Access
      │
      ▼
Remove Old Public Key
```

Never do:

```text
Remove Old Key
      │
      ▼
Generate New Key
      │
      ▼
Try to Connect
```

because one mistake can result in losing access to the server.

---

## SSH Troubleshooting

### Verbose Mode

For SSH authentication problems:

```bash
ssh -v username@server_ip
```

For more detailed debugging:

```bash
ssh -vvv username@server_ip
```

This helps identify:

- Which key SSH is trying
- Authentication methods
- SSH config issues
- Permission issues
- Host key problems
- Server-side authentication failures

---

## Check SSH Service

```bash
sudo systemctl status ssh
```

or:

```bash
sudo systemctl status sshd
```

---

## Check SSH Logs

On systemd-based Linux systems:

```bash
sudo journalctl -u ssh
```

or:

```bash
sudo journalctl -u sshd
```

Depending on the Linux distribution, authentication logs may also be available in:

```text
/var/log/auth.log
```

or:

```text
/var/log/secure
```

---

## Common SSH Errors

| Error | Common Cause |
|-------|--------------|
| `Permission denied (publickey)` | Wrong key, username, permissions, or public key not installed |
| `Connection refused` | SSH service is not listening or the port is blocked |
| `Connection timed out` | Network, firewall, security group, or routing problem |
| `No route to host` | Network routing issue |
| `Host key verification failed` | Problem with the known host entry |
| Private key ignored | Incorrect key path or private-key permissions |

---

## SSH Security Best Practices

```text
Use Ed25519 keys
        │
        ▼
Protect private keys with passphrases
        │
        ▼
Use ssh-agent / OS keychain
        │
        ▼
Disable password authentication when appropriate
        │
        ▼
Disable direct root login
        │
        ▼
Use least-privilege user accounts
        │
        ▼
Protect ~/.ssh permissions
        │
        ▼
Rotate keys according to security policy
        │
        ▼
Monitor SSH authentication logs
```

---

## Quick Revision

```text
SSH
→ Secure remote access.

Private Key
→ Stays on your machine.
→ Never share it.

Public Key
→ Stored on the server.
→ Safe to share.

ssh-keygen
→ Generate SSH keys.

ssh-copy-id
→ Copy public key to a server.

authorized_keys
→ Contains public keys allowed to log in.

ssh-agent
→ Stores unlocked keys in memory.

~/.ssh/config
→ Simplifies SSH configuration.

sshd_config
→ Controls SSH server settings.

sshd -t
→ Tests SSH server configuration.

ssh -v
→ Debug SSH connection problems.

chmod 700 ~/.ssh
→ Protect SSH directory.

chmod 600 ~/.ssh/authorized_keys
→ Protect authorized keys.

chmod 600 ~/.ssh/id_ed25519
→ Protect private key.

chmod 644 ~/.ssh/id_ed25519.pub
→ Protect public key appropriately.
```

---

## Interview Answer

> **"SSH provides secure remote access to Linux servers. With key-based authentication, we generate a private and public key pair. The private key remains on the client machine, while the public key is stored on the server in `~/.ssh/authorized_keys`. During authentication, the client proves that it has the matching private key without sending that private key to the server. In production, I use Ed25519 keys with passphrases, `ssh-agent` or the OS keychain, disable password authentication where appropriate, disable direct root login, and maintain correct SSH permissions. Before changing `sshd_config`, I test a second SSH session and run `sshd -t` before restarting the SSH service. For key rotation, I always add and test the new key first and remove the old key only after confirming the new access works."**

---



# SSH (Secure Shell) — Notes

SSH lets you securely connect to and control a remote machine. It uses **public-key cryptography**: two mathematically linked keys.

- **Private key** — stays on your machine, never shared, never leaves
- **Public key** — safe to share, goes on the servers you want to access

**Core idea:** the server holds your public key. When you connect, your machine proves it holds the matching private key through a cryptographic challenge — the private key itself is never sent anywhere. The server never sees your private key, ever.

---

## 1. Generating a Key Pair

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

| Flag | Meaning |
|------|---------|
| `-t ed25519` | Key type — Ed25519 is modern, fast, and more secure than the older default RSA |
| `-C "comment"` | A label (usually your email) to identify the key later — purely cosmetic, doesn't affect security |

You can also generate it with just:

```bash
ssh-keygen -t ed25519
```

- **Where to save it** → default (`~/.ssh/id_ed25519`) is fine unless you're managing multiple keys
- **Passphrase** → always set one. This encrypts your private key at rest — if your laptop is ever stolen, the key alone is useless without the passphrase

```
~/.ssh/id_ed25519       # PRIVATE key - never share, never leave your machine
~/.ssh/id_ed25519.pub   # PUBLIC key  - safe to share, goes on servers
```

---

## 2. Placing the Public Key on the Server

```bash
ssh-copy-id username@server_ip
```

This automatically appends your public key to the right file on the server (`~/.ssh/authorized_keys`) with correct permissions.

If `ssh-copy-id` is unavailable, use this instead:

```bash
cat ~/.ssh/id_ed25519.pub | ssh username@server_ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Now connect from your current machine to the server:

```bash
ssh username@server_ip
```

If you set a passphrase, you'll be asked for it once per session.

---

## 3. Making It Convenient & Safe — `~/.ssh/config`

Create the file:

```bash
vim ~/.ssh/config
```

```
Host devops-lab
    HostName 192.168.1.50
    User ubuntu
    Port 22
    IdentityFile ~/.ssh/id_ed25519

Host aws-prod
    HostName ec2-xx-xxx-xxx-xxx.compute.amazonaws.com   # host IP or DNS address
    User ec2-user                                        # login user
    IdentityFile ~/.ssh/aws-prod-key.pem                  # path to your pem/identity file
```

Now you can simply run `ssh devops-lab` or `ssh aws-prod`.

> **Scenario:** You manage 10 different servers with different usernames/keys/ports. This file turns all of that into short, memorable names — genuinely one of the highest-value habits to build early.

---

## 4. Setting Up `ssh-agent` — Avoid Retyping Your Passphrase

`ssh-agent` lets you provide your passphrase once per session instead of every time you connect — similar in spirit to SSO.

```bash
eval "$(ssh-agent -s)"      # starts the agent for this terminal session
ssh-add ~/.ssh/id_ed25519   # adds your key, asks for the passphrase ONCE
```

For the rest of this terminal session, `ssh` will use the already-unlocked key without re-prompting.

**Mac-specific:** you can have this persist across reboots by adding the key to the Keychain:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

---

## 5. Hardening the Server Side

```bash
sudo vim /etc/ssh/sshd_config
```

Change the following settings:

```
PasswordAuthentication no    # keys ONLY - no password login at all
PermitRootLogin no           # never allow direct root login
PubkeyAuthentication yes
```

```bash
sudo systemctl restart sshd
```

> **Important:** before restarting, verify key-based login already works. Test it from a **second, separate SSH session** *before* you edit `sshd_config` — never edit this file as your only way in, in case something breaks and locks you out.

After confirming key-based login works, lock down permissions on the `.ssh` folder and its contents:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

---

## 6. Key Rotation

Rotate your keys periodically — every 90 to 180 days.

**The safe rotation sequence (never break access mid-rotation):**

```bash
# 1. Generate a NEW key pair (don't delete the old one yet)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_new -C "rotated $(date +%Y%m%d)"
```
Creates a new key pair (private + public) with a comment noting the rotation date.

```bash
# 2. Add the NEW public key to the server, ALONGSIDE the old one
ssh-copy-id -i ~/.ssh/id_ed25519_new.pub username@server_ip
```
Copies the new public key to the server without removing the old one.

```bash
# 3. Test the NEW key works, in a fresh session
ssh -i ~/.ssh/id_ed25519_new username@server_ip
```

```bash
# 4. ONLY once confirmed working, remove the OLD public key from the server
ssh username@server_ip
nano ~/.ssh/authorized_keys      # delete the old key's line
```

```bash
# 5. Replace your local default key
mv ~/.ssh/id_ed25519_new ~/.ssh/id_ed25519
mv ~/.ssh/id_ed25519_new.pub ~/.ssh/id_ed25519.pub
```

> **Core principle:** always keep a working path back in **before** removing the old key.
