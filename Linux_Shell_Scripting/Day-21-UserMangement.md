# Linux Users, Groups & File Permissions

## Creating a User

    sudo useradd -m -s /bin/bash -c "Prudhvi DevOps Engineer" prudhvi
    sudo passwd prudhvi

### Options

- `-m` → Creates a home directory for the user.
- `-s /bin/bash` → Sets the user's login shell to `/bin/bash`.
- `-c` → Adds a comment/description for the user.

> Correct command: `sudo passwd prudhvi`  
> The `passwd` command expects the **username**, not the password as an argument.

### Home Directory Permissions

The permissions of a newly created home directory depend on the system configuration and `umask`.

Commonly, a home directory may be created with permissions such as:

    700
    or
    755

For example:

    700 → Owner: read, write, execute
          Group: no access
          Others: no access

    755 → Owner: read, write, execute
          Group: read, execute
          Others: read, execute

> Do not assume that every Linux system creates home directories with exactly `700` or `755`. The result depends on the distribution and configuration.

# Creating a Group

Create a group:

    sudo groupadd devops

Add a user to the group:

    sudo usermod -aG devops prudhvi

- `-a` → Append the user to the existing supplementary groups.
- `-G` → Specifies the supplementary group(s).

> Using `-aG` is important. Without `-a`, existing supplementary group memberships can be replaced.

Create another user and add the user to the `devops` group:

    sudo useradd -m -s /bin/bash -G devops gopal

Or add the user after creation:

    sudo usermod -aG devops gopal

Check the groups a user belongs to:

    groups prudhvi
    groups gopal

# Shared Project Directory

### Scenario

`prudhvi` and `gopal` need access to a shared project directory, but users outside the team should not have access.

Create the directory:

    sudo mkdir -p /srv/project

Change the group ownership:

    sudo chown :devops /srv/project

Set permissions:

    sudo chmod 770 /srv/project

### Permission Breakdown

    770

    Owner → rwx
    Group → rwx
    Others → ---

Therefore:

- The owner has full access.
- Members of the `devops` group have full access.
- Other users have no access.

> The directory must also have the correct group membership for the users to access it.

# Switching to Another User

Switch to `prudhvi`:

    su - prudhvi

This prompts for `prudhvi`'s password.

You can also use:

    sudo su - prudhvi

This uses your current user's `sudo` privileges to start a login shell as `prudhvi`.

> `sudo su - prudhvi` is generally less preferred than using `sudo -iu prudhvi` when you specifically need a login shell as that user.

# Service Accounts

Service accounts are used for applications and services that do not require interactive human login.

Example:

    sudo useradd -r -s /usr/sbin/nologin -M appuser

### Options

- `-r` → Creates a system user, generally used for services.
- `-s /usr/sbin/nologin` → Prevents interactive login through that account.
- `-M` → Does not create a home directory.

Check the user's information:

    id appuser

Example output:

    uid=995(appuser) gid=995(appuser) groups=995(appuser)

The `uid` is the user's unique ID.

> The exact UID range for system users depends on the Linux distribution and configuration.

### Production Use Case

Suppose an application runs as a `systemd` service.

A unit file can specify:

    [Service]
    User=appuser

This makes the application run as `appuser` instead of `root`.

This follows the **principle of least privilege**:

- The application gets only the permissions it needs.
- If the application is compromised, the potential impact is reduced compared with running it as `root`.

# Shared Directory Permissions

## Scenario A — Everyone Can Read, Only the Owner Can Modify

Create the directory:

    sudo mkdir -p /srv/readOnly-share

Set ownership:

    sudo chown root:devops /srv/readOnly-share

Set permissions:

    sudo chmod 755 /srv/readOnly-share

### Permission Breakdown

    755

    Owner → rwx
    Group → r-x
    Others → r-x

Therefore:

- The owner can read, write, and enter the directory.
- Group members can read/list and enter the directory.
- Other users can read/list and enter the directory.
- Only the owner can create or delete files in the directory.

> For directories, the `w` permission controls the ability to create, delete, and rename entries.

## Scenario B — Shared Workspace with Sticky Bit

Suppose multiple users need to work inside the same directory.

Create the directory:

    sudo mkdir -p /srv/shared-workspace

Set ownership:

    sudo chown root:developers /srv/shared-workspace

Set permissions:

    sudo chmod 1770 /srv/shared-workspace

### Permission Breakdown

    1770

    1    → Sticky bit
    770  → Owner and group have full access, others have no access

The **sticky bit** means that files inside the directory can generally be deleted or renamed only by:

- The file owner
- The directory owner
- `root`

Example:

    sudo -u prudhvi touch /srv/shared-workspace/prudhvi-file.txt
    sudo -u gopal touch /srv/shared-workspace/gopal-file.txt

With the sticky bit:

- `prudhvi` can delete their own file.
- `gopal` can delete their own file.
- `prudhvi` cannot delete `gopal`'s file.
- `gopal` cannot delete `prudhvi`'s file.
- `root` can delete either file.

### Important: Sticky Bit Does Not Prevent File Modification

The sticky bit controls **deletion and renaming**, not modification of file contents.

For example, if a file has:

    -rw-rw-r--

then another user in the same group may still be able to modify that file.

Therefore, this statement is incorrect:

> "Users cannot touch each other's files."

The sticky bit only prevents them from **deleting or renaming** each other's files.

If users must also be prevented from modifying each other's files, file permissions, `umask`, ACLs, or another access-control mechanism must be configured appropriately.

# Quick Revision

| Command / Concept | Purpose |
|---|---|
| `useradd` | Creates a user |
| `passwd` | Sets or changes a user's password |
| `groupadd` | Creates a group |
| `usermod -aG` | Adds a user to a supplementary group |
| `groups username` | Shows the user's group memberships |
| `id username` | Shows UID, GID, and groups |
| `su - username` | Switches to another user |
| `useradd -r` | Creates a system/service user |
| `/usr/sbin/nologin` | Prevents interactive login |
| `chown` | Changes owner/group ownership |
| `chmod` | Changes file/directory permissions |
| `770` | Owner and group: full access; others: no access |
| `755` | Owner: full access; group/others: read + execute |
| `1770` | `770` permissions + sticky bit |
| Sticky bit | Restricts deletion/renaming of other users' files |
