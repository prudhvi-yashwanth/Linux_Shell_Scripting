# Linux Commands – Complete Revision Guide (DevOps)

Prepared 03-Oct-2026 · Consolidated from your Linux class notes, command sheet, and SOPs · Commands run on Ubuntu/Debian unless noted

**How to use this guide:** Sections follow the order you should learn and use them on a real server: first help and navigation, then files, searching, processes, users, permissions, packages, services, networking, automation, and remote access. Each section has commands with examples, plus interview points and troubleshooting where they matter.

---

## 1. Basics – System Info, Help and Shell Tricks

| Command | Purpose | Example |
| --- | --- | --- |
| `uname -a` | OS and kernel details | `uname -a` |
| `hostname` | Server name | `hostname` |
| `uptime` | How long server is running + load average | `uptime` |
| `date` | Current date and time | `date` |
| `whoami` | Current logged-in user | `whoami` |
| `id` | User ID, group ID, all groups | `id bharath` |
| `clear` | Clear terminal screen | `clear` |
| `history` | Previously used commands | `history` |
| `man <cmd>` | Full manual of a command (press `q` to exit) | `man ls` |
| `<cmd> --help` | Quick summary of options | `ls --help` |
| `help <builtin>` | Help for shell built-ins like `cd`, `export` | `help cd` |
| `alias` | Create a shortcut | `alias ll='ls -l'` |
| `exit` | Logout or return to previous user | `exit` |

**Reading `uptime` output:** `10:30:15 up 5 days, 3:20, 2 users, load average: 0.45, 0.30, 0.25`. Load average is for the last 1, 5 and 15 minutes. If it is below the number of CPU cores, the server is fine. If it is above, the server is overloaded.

**Interview:** *What is the difference between `man` and `--help`?* `man` gives the full manual. `--help` gives a short summary. `help` works only for shell built-ins.

---

## 2. sudo, su and su -

| Command | What happens | Example |
| --- | --- | --- |
| `sudo <cmd>` | Runs only this one command as root (uses your own password) | `sudo apt update` |
| `su` | Switch user to root, but keeps your old environment | `su` |
| `su -` | Switch to root with root's full login environment (HOME becomes `/root`) | `su -` |
| `sudo su` | Root, but with your user's environment | `sudo su` |
| `sudo su -` | Root with root's environment | `sudo su -` |

**Demo to remember the difference:**

```bash
sudo su
echo $HOME      # /home/azureuser  (user environment)
exit
sudo su -
echo $HOME      # /root  (root environment)
```

**Real-life tip:** `sudo cd /root` does NOT work, because `cd` is a shell built-in. Use `sudo su -` first, then `cd /root`.

**Interview:** *Which is best practice?* `sudo` for single commands. It is logged, controlled by `/etc/sudoers`, and safer than logging in as root.

---

## 3. Navigation – pwd, cd, ls

### 3.1 pwd and cd

| Command | Purpose | Example |
| --- | --- | --- |
| `pwd` | Show current directory | `pwd` |
| `cd <dir>` | Go to a directory (relative path) | `cd Documents` |
| `cd /path` | Go to an absolute path | `cd /var/log` |
| `cd` or `cd ~` | Go to home directory | `cd ~` |
| `cd ..` | One level up | `cd ..` |
| `cd ../..` | Two levels up | `cd ../..` |
| `cd -` | Go back to the previous directory | `cd -` |
| `cd ~user` | Go to another user's home | `cd ~bharath` |
| `cd "My Folder"` or `cd My\ Folder` | Folder names with spaces | `cd "My Folder"` |

**Symbols:** `/` root · `.` current directory · `..` parent · `~` home · `-` previous directory.

**Absolute vs relative path:** Absolute starts from `/` (example `/etc/nginx`). Relative starts from where you are now (example `nginx`). Use absolute paths in scripts.

**Common errors:** `No such file or directory` means wrong path (check with `ls`). `Permission denied` means no access (use `sudo` or switch user).

### 3.2 ls – list files

| Command | What it does | When to use |
| --- | --- | --- |
| `ls` | Basic list | Quick look |
| `ls -l` | Permissions, owner, size, date | Detailed info |
| `ls -a` | Include hidden files (starting with `.`) | See config files |
| `ls -la` | Long + hidden | Most common |
| `ls -lh` | Human-readable sizes (KB, MB) | Easy reading |
| `ls -lt` | Newest first | Find recent changes |
| `ls -ltr` | Oldest first | Latest file at the bottom |
| `ls -lS` | Largest first | Disk analysis |
| `ls -R` | Recursive | See folder tree |
| `ls -ld <dir>` | Info about the directory itself | Check directory permissions |
| `ls -i` | Show inode number | Troubleshooting, links |
| `ls -F` | Add type marks (`/` for folder, `*` for executable) | Identify file type |
| `ls -1` | One item per line | Scripts |
| `ls --color=auto` | Coloured output | Readability |
| `ls --group-directories-first` | Folders first | Cleaner view |

---

## 4. Create, Copy, Move and Delete Files and Folders

### 4.1 Create files

| Command | Effect | Example |
| --- | --- | --- |
| `touch <file>` | Creates empty file (or updates timestamp) | `touch app.log` |
| `echo "text" > <file>` | Creates file and writes text (**overwrites**) | `echo "Hello" > welcome.txt` |
| `echo "text" >> <file>` | **Appends** a line | `echo "2nd line" >> welcome.txt` |
| `cat > <file>` | Type content, then Ctrl+D to save | `cat > notes.txt` |

### 4.2 Create folders

| Command | Effect | Example |
| --- | --- | --- |
| `mkdir <dir>` | Create directory | `mkdir my_projects` |
| `mkdir -p <path>` | Create parent folders too | `mkdir -p /home/user/documents/2026/october` |

### 4.3 Copy – cp

| Command | Effect |
| --- | --- |
| `cp file1 file2` | Copy file in same folder |
| `cp file1.txt destination/` | Copy file into another folder |
| `cp file1.txt destination/newfile.txt` | Copy with new name |
| `cp -r folder1 destination/` | Copy folder (`-r` = recursive) |
| `cp -r folder1 destination/project_backup` | Copy folder with new name |
| `cp -i` | Ask before overwrite |
| `cp -v` | Show what is copied |

### 4.4 Move and rename – mv

In Linux, **rename = move**.

| Command | Effect |
| --- | --- |
| `mv file1.txt destination/` | Move file |
| `mv file2.txt destination/newfile.txt` | Move and rename |
| `mv old.txt new.txt` | Rename file |
| `mv folder1 destination/` | Move folder |
| `mv folder2 Project` | Rename folder |
| `mv file1.txt file2.txt archive/` | Move many files |
| `mv -i` / `mv -v` | Confirm overwrite / verbose |

**Warning:** `mv` overwrites without asking by default. Use `mv -i` in important folders.

### 4.5 Delete – rm and rmdir

| Command | Effect | Notes |
| --- | --- | --- |
| `rm file.txt` | Delete file | Basic |
| `rm a.txt b.txt` | Delete many files |  |
| `rm -i file.txt` | Ask before deleting | Safe |
| `rm -f file.txt` | Force, no prompt |  |
| `rm -v file.txt` | Show what is deleted |  |
| `rm -r dir` | Delete folder and contents | Recursive |
| `rm -ri dir` | Recursive + confirm | Safer |
| `rm -rf dir` | Force delete folder | **Dangerous** |
| `rm *.log` | Delete by pattern | Wildcard |
| `rm -rf /tmp/*` | Delete contents, keep the folder |  |
| `rmdir dir` | Delete empty directory only | Fails if not empty |
| `rmdir -p a/b/c` | Delete empty parent folders too |  |

**Never run** `rm -rf /` or `rm -rf / --no-preserve-root`. It destroys the whole system. Always double-check the path before pressing Enter.

**Practice lab:**

```bash
mkdir ~/linux-lab && cd ~/linux-lab
mkdir source destination backup folder1 folder2
touch file1.txt file2.txt
cp file1.txt destination/
cp -r folder1 destination/
mv file2.txt destination/newfile.txt
rm -ri backup
```

---

## 5. Viewing File Content

| Command | Purpose | Example |
| --- | --- | --- |
| `cat file` | Show full file | `cat test.txt` |
| `cat file1 file2` | Show many files together | `cat a.txt b.txt` |
| `cat -n file` | Number all lines | `cat -n app.log` |
| `cat -b file` | Number only non-empty lines | `cat -b app.log` |
| `cat -s file` | Squeeze repeated blank lines | `cat -s app.log` |
| `cat -E file` | Show `$` at line end (find hidden spaces) | `cat -E app.conf` |
| `cat -T file` | Show tabs as `^I` | `cat -T app.conf` |
| `cat -A file` | Show all hidden characters | `cat -A app.conf` |
| `less file` | Read page by page (`q` to quit) | `less large.log` |
| `head file` | First 10 lines | `head test.txt` |
| `head -n 20 file` | First 20 lines | `head -n 20 app.log` |
| `tail file` | Last 10 lines | `tail test.txt` |
| `tail -n 50 file` | Last 50 lines | `tail -n 50 app.log` |
| `tail -f file` | **Live log monitoring** | `tail -f /var/log/nginx/access.log` |

**Production use:** After a deployment, run `tail -f app.log` in one terminal to watch errors live.

---

## 6. Editors – nano and vi

**nano** (easy): `nano app.conf` → type → `Ctrl+O`, Enter to save → `Ctrl+X` to exit.

**vi/vim** (available on every server, so you must know it). It has modes:

| Mode | How to enter | Purpose |
| --- | --- | --- |
| Normal | `Esc` | Navigation and commands |
| Insert | `i`, `a`, `o` | Typing text |
| Command | `:` | Save, quit, search, settings |
| Visual | `v`, `V`, `Ctrl+v` | Select text |

| Task | Keys |
| --- | --- |
| Insert before / after cursor | `i` / `a` |
| Insert at line start / end | `I` / `A` |
| New line below / above | `o` / `O` |
| Save · quit · save and quit | `:w` · `:q` · `:wq` (or `:x`, `ZZ`) |
| Quit without saving | `:q!` |
| Go to top / bottom / line n | `gg` / `G` / `:n` |
| Start / end of line | `0` / `$` |
| Delete character / line / word | `x` / `dd` / `dw` |
| Copy line / paste after | `yy` / `p` |
| Undo / redo | `u` / `Ctrl+r` |
| Search forward / next match | `/word` / `n` |
| Replace all in file | `:%s/old/new/g` |
| Show / hide line numbers | `:set number` / `:set nonumber` |
| Run shell command | `:!ls` |
| Insert another file | `:r file` |

**Memory trick:** `i` = insert, `Esc` = escape, `:` = command, `dd` = delete line, `yy` = copy, `p` = paste.

**Interview:** *How do you exit vi without saving?* `Esc`, then `:q!`.

---

## 7. Searching – grep, find, locate, which, whereis

### 7.1 grep (search text inside files)

| Command | Purpose |
| --- | --- |
| `grep "error" app.log` | Find lines with "error" (case-sensitive) |
| `grep -i "error" app.log` | Ignore case |
| `grep -n "error" app.log` | Show line numbers |
| `grep -w "error" app.log` | Match whole word only |
| `grep -v "error" app.log` | Lines that do NOT match |
| `grep -c "fail" app.log` | Count matching lines |
| `grep -r "error" /var/log` | Search recursively in a folder |
| `grep -C 2 "error" app.log` | Show 2 lines before and after (context) |
| `grep -v "^#" app.conf` | Hide comment lines from a config |
| `grep --color=auto "error" app.log` | Highlight matches |

Combine with other commands using a pipe: `cat app.log | grep -i error`, or `ps -ef | grep nginx`.

### 7.2 Finding files and commands

| Command | Purpose | Example |
| --- | --- | --- |
| `find / -name <file>` | Find file anywhere | `find / -name nginx.conf` |
| `locate <file>` | Fast search using an index database | `locate sshd_config` |
| `which <cmd>` | Path of the command that runs | `which python` |
| `whereis <cmd>` | Binary, source and manual locations | `whereis nginx` |

---

## 8. Links and Inodes (Soft Link vs Hard Link)

| Command | Purpose |
| --- | --- |
| `ln -s file1.txt file1_soft` | Create symbolic (soft) link |
| `ln file1.txt file1_hard` | Create hard link |
| `ls -l` | Soft link shows `l` and `->` |
| `ls -li` | Show inode numbers |
| `df -i` | Inode usage of filesystem |
| `file link.txt` | Says "symbolic link to ..." |
| `readlink link.txt` | Shows soft link target |
| `unlink shortcut.txt` | Remove a link (original is safe) |

**Example:**

```bash
echo "Hello" > original.txt
ln -s original.txt shortcut.txt      # soft link
ln original.txt hardcopy.txt         # hard link
ls -li                               # hardcopy has SAME inode, shortcut has DIFFERENT inode
rm original.txt
cat shortcut.txt                     # error: broken link
cat hardcopy.txt                     # still works
```

| Feature | Soft link | Hard link |
| --- | --- | --- |
| Inode | Different | Same |
| Works across filesystems | Yes | No |
| Can link directories | Yes | No |
| Breaks if original deleted | Yes | No |
| Link count increases | No | Yes |

**Real use:** `current -> release_2026_10` symlink for instant rollback in deployments; `/usr/java -> /usr/java/jdk17` to switch versions.

**Interview one-liner:** A symbolic link is a shortcut with its own inode. A hard link is another name for the same inode.

---

## 9. Disk and Memory

| Command | Purpose | Example |
| --- | --- | --- |
| `df -h` | Free and used space per filesystem | `df -h` |
| `df -Th` | Same + filesystem type | `df -Th` |
| `df -ih` | Inode usage | `df -ih` |
| `du -sh <dir>` | Total size of a folder | `du -sh /opt/app` |
| `du -sh *` | Size of each item here | `du -sh *` |
| `du -h --max-depth=1` | One level of sizes | `du -h --max-depth=1 /var` |
| `du -ah /var/log` + `sort -h` | Find big files | `du -ah /var/log \| sort -h` |
| `free -h` | RAM and swap usage | `free -h` |
| `swapon --show` | Show swap | `swapon --show` |

**du vs ls:** `ls` shows the file's logical size. `du` shows the real disk space used.

**Swap** is disk space used as extra memory when RAM is full. It is slower than RAM but avoids Out-Of-Memory crashes. Swap file is easy to resize and common in cloud. Swap partition is slightly faster.

**Troubleshooting – disk full:**

```bash
df -h                          # which filesystem is full?
du -h --max-depth=1 /var       # which folder is big?
du -ah /var/log | sort -h | tail   # which files are biggest?
df -i                          # also check inodes (can be full even if space is free)
```

---

## 10. Process Management

| Command | Purpose | Example |
| --- | --- | --- |
| `top` | Live CPU and memory view | `top` |
| `htop` | Better, colourful version (`sudo apt install htop -y`) | `htop` |
| `ps -ef` | All processes (full format) | `ps -ef \| grep nginx` |
| `ps aux` | All processes (alternate view) | `ps aux` |
| `sleep 500 &` | Start a dummy background process | `sleep 500 &` |
| `pgrep <name>` | PID by process name | `pgrep sleep` |
| `pidof <name>` | PID of a program | `pidof sleep` |
| `kill <PID>` | Graceful stop (SIGTERM, 15) | `kill 3456` |
| `kill -9 <PID>` | Force stop (SIGKILL) | `kill -9 3456` |
| `pkill <name>` | Kill by name | `pkill nginx` |
| `killall <name>` | Kill all with this name | `killall nginx` |
| `jobs` | Show background jobs | `jobs` |
| `bg` / `fg` | Run job in background / bring to foreground | `fg` |

**Keys inside top:** `P` sort by CPU · `M` sort by memory · `T` sort by time · `k` kill · `r` renice · `h` help · `q` quit. **Keys inside htop:** `F3` search · `F4` filter · `F5` tree view · `F6` sort · `F9` kill · `F10` exit.

**top output meaning:** CPU line: `us` user, `sy` kernel, `id` idle, `wa` waiting for I/O (high `wa` means disk problem). Columns: PID, USER, PR, NI, VIRT, RES, SHR, S (state), %CPU, %MEM, TIME+, COMMAND.

| Signal | Number | Command | Meaning |
| --- | --- | --- | --- |
| SIGHUP | 1 | `kill -1 PID` | Reload configuration |
| SIGKILL | 9 | `kill -9 PID` | Force kill |
| SIGTERM | 15 | `kill PID` | Graceful stop (default) |
| SIGSTOP | 19 | `kill -19 PID` | Pause |
| SIGCONT | 18 | `kill -18 PID` | Resume |

**Practice lab:**

```bash
sleep 500 &                 # start process
ps -ef | grep sleep         # note the PID, e.g. 3456
kill 3456                   # try graceful first
kill -9 3456                # only if it did not stop
ps -ef | grep sleep         # confirm it is gone
```

**Troubleshooting – server is slow:** `uptime` (load) → `top` (who is using CPU or memory) → note PID → `kill` or restart the service → `free -h` (memory/swap) → `df -h` (disk).

**Interview:** *Why try `kill` before `kill -9`?* SIGTERM lets the app close files and connections cleanly. SIGKILL cannot be caught, so data can be lost.

---

## 11. Users and Groups

| Task | Command |
| --- | --- |
| List users | `cat /etc/passwd` or `getent passwd` |
| List groups | `cat /etc/group` or `getent group` |
| Describe a user (UID, GID, groups) | `id bharath` |
| Describe a group | `getent group dev` |
| Groups of a user | `groups bharath` |
| Create user (no home folder) | `sudo useradd bharath_test` |
| Create user with home folder | `sudo useradd -m bharath` |
| Create user (interactive wizard, Ubuntu) | `sudo adduser ravi` |
| Set password | `sudo passwd bharath` |
| Create group | `sudo groupadd dev` |
| Create user with primary group | `sudo useradd -m -g tech_team ravi` |
| Create user with extra groups | `sudo useradd -m -G dev,marketing tom` |
| Full example with shell | `sudo useradd -m -g tech_team -G dev,marketing -s /bin/sh complete_user` |
| Change primary group | `sudo usermod -g dev bharath` |
| **Add to groups safely (append)** | `sudo usermod -aG dev,tech_team bharath` |
| Give sudo access (Ubuntu) | `sudo usermod -aG sudo bharath` |
| Give sudo access (RHEL) | `sudo usermod -aG wheel bharath` |
| Remove user from group | `sudo gpasswd -d bharath dev` (or `sudo deluser bharath dev`) |
| Delete user | `sudo userdel tom` |
| Delete user + home folder | `sudo userdel -r nick` (or `sudo deluser --remove-home nick`) |
| Delete group | `sudo groupdel marketing` (or `sudo delgroup marketing`) |

**Key points:**

- `useradd` without `-m` creates no home folder. `adduser` (Ubuntu) creates home and asks for details.
- Always use `-aG` (append). `-G` alone **replaces** all existing supplementary groups.
- `-g` = primary group, `-G` = supplementary groups.
- `/etc/passwd` has users (name, UID, home, shell). `/etc/group` has groups. `id <user>` is the best debugging command.

**Full demo flow:**

```bash
sudo useradd -m bharath && sudo useradd -m ravi
sudo passwd bharath
sudo groupadd dev && sudo groupadd tech_team
sudo usermod -aG dev,tech_team bharath
id bharath
sudo gpasswd -d bharath dev
sudo userdel -r ravi
```

---

## 12. Permissions and Ownership

Read `ls -l` output like this: `-rwxr-xr-- 1 owner group size date name`. The first character is the type (`-` file, `d` directory, `l` link). Then three sets: owner, group, others.

**Numeric values:** r = 4, w = 2, x = 1. Add them per set.

| Number | Meaning |
| --- | --- |
| 7 | rwx |
| 6 | rw- |
| 5 | r-x |
| 4 | r-- |
| 0 | --- |

### chmod – change permissions

| Command | Result |
| --- | --- |
| `chmod 744 file` | Owner rwx, others read only |
| `chmod 755 script.sh` | Owner rwx, others r-x (common for scripts and folders) |
| `chmod 700 file` | Only owner has access |
| `chmod 600 file` | Owner read/write (SSH keys and `authorized_keys`) |
| `chmod 400 key.pem` | Owner read only (private key) |
| `chmod +x run.sh` | Make executable |
| `chmod g+w file` | Add write for group |
| `chmod o-rwx file` | Remove all from others |
| `chmod a=rw file` | Set read/write for all |
| `chmod u+x,o-w file` | Multiple changes at once |
| `chmod -R 755 dir` | Apply to folder and everything inside |

**Symbols:** who = `u` user, `g` group, `o` others, `a` all · operation = `+` add, `-` remove, `=` set exactly.

### chown and chgrp – change owner and group

| Command | Use case |
| --- | --- |
| `chown bharath file.txt` | Change owner |
| `chown bharath:dev file.txt` | Change owner and group |
| `chown :marketing file.txt` | Change only group |
| `chgrp devops file.txt` | Change group |
| `chown -R bharath:dev /var/www/html` | Fix web server deployment folder |
| `chown -R tom:tech_team /var/log/app` | Let the app write logs |
| `chown -R 1000:1000 /data` | Use UID:GID (fix Docker volume permissions) |
| `chown --reference=file1 file2` | Copy ownership from another file |
| `chown -v bharath:dev file.txt` | Verbose output |

**Troubleshooting – "Permission denied":** `ls -l file` (check owner and permissions) → `id` (who am I and my groups) → fix with `chmod` or `chown`, or use `sudo`.

---

## 13. Package Management (APT for Ubuntu/Debian)

Think of the repository as a warehouse of packages, and APT as the librarian. **Ubuntu/Debian** uses `.deb` packages with **APT**. **Red Hat/CentOS** uses `.rpm` packages with **YUM/DNF**.

Run this flow in order:

| Step | Command | Meaning |
| --- | --- | --- |
| 1 | `sudo apt update` | Refresh package list (always first; installs nothing) |
| 2 | `sudo apt install apache2 -y` | Install (`-y` = auto yes) |
| 3 | `sudo apt install cowsay apache2` | Install many packages together |
| 4 | `apache2 -v` · `nginx -v` · `tree --version` | Check installed version |
| 5 | `apt list -a nginx` | See all available versions |
| 6 | `sudo apt install nginx=1.18.0-0ubuntu1` | Install a specific version (must match `apt list -a` exactly) |
| 7 | `sudo apt upgrade -y` | Upgrade all packages |
| 8 | `sudo apt install --only-upgrade nginx` | Upgrade one package only |
| 9 | `sudo apt full-upgrade -y` | Upgrade and handle dependency changes |
| 10 | `sudo apt-mark hold nginx` | Stop a package from auto-upgrading |
| 11 | `apt-mark show-hold` | List held packages |
| 12 | `sudo apt-mark unhold nginx` | Allow upgrades again |
| 13 | `sudo apt remove nginx -y` | Remove package, **keep config** |
| 14 | `sudo apt purge nginx -y` | Remove package **and config** |
| 15 | `sudo apt autoremove -y` | Remove unused dependencies |

**Interview line:** `remove` = program gone, config stays. `purge` = everything gone.

**End-to-end example:**

```bash
sudo apt update
sudo apt install apache2 -y
systemctl status apache2
apache2 -v
apt list -a apache2
sudo apt install apache2 --only-upgrade -y
sudo apt-mark hold apache2
sudo apt remove apache2 -y
sudo apt purge apache2 -y
sudo apt autoremove -y
```

**Why upgrade?** New features, bug fixes, and security patches (for example, an SSH vulnerability fix).

---

## 14. Services and Logs – systemctl and journalctl

| Command | Purpose |
| --- | --- |
| `sudo systemctl status nginx` | Is the service running? |
| `sudo systemctl start nginx` | Start now |
| `sudo systemctl stop nginx` | Stop now |
| `sudo systemctl restart nginx` | Stop and start again |
| `sudo systemctl enable nginx` | Auto-start at boot |
| `sudo systemctl disable nginx` | Do not start at boot |
| `systemctl list-units --type=service` | Running services |
| `systemctl list-unit-files --type=service` | All services |
| `journalctl` | All system logs |
| `journalctl -u nginx` | Logs of one service |
| `sudo reboot` | Restart server |
| `ss -tulnp \| grep nginx` | Check the service is listening on its port |
| `curl localhost` | Test the web page locally |

**Troubleshooting – service will not start:**

```bash
systemctl status nginx          # see the error summary
journalctl -u nginx             # read detailed logs
ss -tulnp | grep 80             # is another process using the port?
sudo nginx -t                   # test config syntax (for nginx)
```

---

## 15. Networking and Firewall

| Command | Purpose | Example |
| --- | --- | --- |
| `ip a` | Show IP addresses | `ip a` |
| `ping <host>` | Check connectivity | `ping google.com` |
| `curl <url>` | Test a URL or API | `curl http://localhost` |
| `wget <url>` | Download a file | `wget https://example.com/file.zip` |
| `ss -tulpn` | Open ports and the process using them | `ss -tulpn` |
| `netstat -tulpn` | Same (older tool) | `netstat -tulpn` |
| `sudo ufw enable` | Turn on firewall | `sudo ufw enable` |
| `sudo ufw status` | Firewall status | `sudo ufw status` |
| `sudo ufw allow 22` | Allow SSH port | `sudo ufw allow 22` |
| `sudo ufw deny 23` | Block telnet | `sudo ufw deny 23` |

**Important:** allow port 22 **before** enabling `ufw`, or you may lock yourself out of the server. On Azure, also open port 22 in the Network Security Group.

**Troubleshooting – cannot reach an app:** `ping` (network up?) → `ip a` (correct IP?) → `ss -tulpn` (app listening?) → `ufw status` (firewall blocking?) → `curl localhost` (works locally?).

---

## 16. Who Is Logged In

| Command | Purpose |
| --- | --- |
| `who` | Users logged in now |
| `w` | Users and what they are doing |
| `last` | Login history |

---

## 17. Archive and Compress

| Command | Purpose | Example |
| --- | --- | --- |
| `tar -czvf a.tgz dir` | Create compressed archive | `tar -czvf backup.tgz data` |
| `tar -xzvf a.tgz` | Extract archive | `tar -xzvf backup.tgz` |
| `zip -r a.zip dir` | Zip a folder | `zip -r app.zip app` |
| `unzip a.zip` | Extract zip | `unzip app.zip` |

**Memory:** `c` create, `x` extract, `z` gzip, `v` verbose, `f` file name.

---

## 18. Cron – Scheduling Jobs

**Cron** is the background service that checks every minute. **Crontab** is the table (file) of jobs.

**Syntax:** `minute hour day-of-month month weekday command`

| Field | Range |
| --- | --- |
| Minute | 0–59 |
| Hour | 0–23 |
| Day of month | 1–31 |
| Month | 1–12 |
| Weekday | 0–6 (0 = Sunday) |

| Command | Purpose |
| --- | --- |
| `crontab -e` | Edit your jobs |
| `crontab -l` | List your jobs |
| `crontab -r` | Remove all your jobs |
| `sudo crontab -u <user> -e` | Edit another user's jobs |

**Schedule examples:**

```bash
* * * * *     /home/azureuser/track_time.sh      # every minute
0 2 * * *     /opt/scripts/backup.sh             # every day at 2:00 AM
*/5 * * * *   /opt/scripts/health_check.sh       # every 5 minutes
30 9 * * 1    /opt/scripts/weekly_report.sh      # every Monday 9:30 AM
```

**Demo – log the time every minute:**

```bash
nano /home/azureuser/track_time.sh
#!/bin/bash
echo "The current time is: $(date)" >> /home/azureuser/output.txt

chmod +x /home/azureuser/track_time.sh      # must be executable
crontab -e                                  # add the * * * * * line
tail -f /home/azureuser/output.txt          # watch it grow every minute
```

**Real use:** log cleanup, backups, health checks. The script handles *what* to do. Crontab handles *when*.

---

## 19. SSH and Remote Access

| Command | Purpose | Example |
| --- | --- | --- |
| `ssh user@ip` | Login to a server | `ssh dev@10.0.0.1` |
| `ssh -i key.pem user@ip` | Login using a private key | `ssh -i linuxuser.pem linuxuser@20.51.142.23` |
| `ssh-keygen` | Generate key pair | `ssh-keygen -t rsa -b 4096 -f linuxuser` |
| `ssh-copy-id user@ip` | Copy public key for passwordless login | `ssh-copy-id dev@10.0.0.1` |
| `scp file user@ip:/path` | Copy file to server | `scp a.txt dev@10.0.0.1:/tmp` |
| `rsync -av src dst` | Sync folders (only changes) | `rsync -av /data /backup` |

### Key-based login from Windows (step by step)

```bash
# Step 1 – On Windows PowerShell: create key pair
ssh-keygen -t rsa -b 4096 -f linuxuser
rename-item linuxuser linuxuser.pem          # private key (keep safe)

# Step 2 – On Linux server: create the user
sudo adduser linuxuser
sudo usermod -aG sudo linuxuser              # optional admin rights

# Step 3 – Set up the public key
sudo su - linuxuser
mkdir -p ~/.ssh && chmod 700 ~/.ssh
touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
nano ~/.ssh/authorized_keys                  # paste contents of linuxuser.pub (ONE single line)

# Step 4 – Fix ownership (very important)
chown -R linuxuser:linuxuser /home/linuxuser/.ssh

# Step 5 – Connect from Windows
ssh -i linuxuser.pem linuxuser@<VM_IP>
```

**Copy the key from Windows to VM1 and hop to VM2:**

```bash
scp linuxuser.pem linuxuser@<VM1_IP>:/home/linuxuser/     # run on Windows
chmod 400 /home/linuxuser/linuxuser.pem                   # run on VM1
ssh -i linuxuser.pem linuxuser@<VM2_IP>                   # run on VM1
```

**PuTTY option:** PuTTYgen → Load `.pem` → Save private key as `.ppk` → in PuTTY enter `user@public_ip` → Connection → SSH → Auth → Credentials → Browse `.ppk` → Open.

**Troubleshooting SSH:**

| Error | Likely cause and fix |
| --- | --- |
| Connection refused / timed out | Port 22 not open in NSG or firewall; SSH service not running |
| Permission denied (publickey) | Wrong key, public key pasted with line breaks, or wrong permissions on `.ssh` (700) and `authorized_keys` (600) |
| Unprotected private key file | Fix with `chmod 400 key.pem` (on Windows, remove extra users from file Security) |

---

## 20. Mounting and Kernel Messages

| Command | Purpose | Example |
| --- | --- | --- |
| `mount` | Show mounts, or mount a device | `sudo mount /dev/sdb1 /mnt` |
| `umount <path>` | Unmount | `sudo umount /mnt` |
| `dmesg` | Kernel messages (hardware, disk errors) | `dmesg \| tail` |
| `watch <cmd>` | Repeat a command every 2 seconds | `watch df -h` |

---

## 21. Linux Directory Structure (Quick Table)

| Directory | What is inside | DevOps use |
| --- | --- | --- |
| `/` | Root of everything | Starting point |
| `/home` | User home folders | User files, `.ssh`, `.bashrc` |
| `/root` | Root user's home | Admin only |
| `/etc` | Configuration files | `/etc/passwd`, `/etc/ssh/sshd_config`, `/etc/nginx/nginx.conf` |
| `/var` | Changing data and logs | `cd /var/log` for debugging |
| `/tmp` | Temporary files | Cleared on reboot |
| `/bin`, `/sbin` | Essential user and admin commands | `ls`, `cp`, `reboot`, `fsck` |
| `/usr` | Installed applications and libraries | `/usr/bin`, `/usr/local/bin` |
| `/lib`, `/lib64` | Shared libraries | Needed by `/bin` and `/sbin` |
| `/opt` | Third-party software | Manual app installs |
| `/boot` | Kernel and GRUB bootloader | System cannot start without it |
| `/dev` | Device files | `/dev/sda`, `/dev/null` |
| `/proc` | Live process and system info | `/proc/cpuinfo`, `/proc/meminfo` |
| `/sys` | Kernel and hardware interface | Tuning |
| `/mnt`, `/media` | Mount points | Extra disks, USB |

**Key ideas:** Everything is a file in Linux. There are no drive letters (no C: or D:). All storage is mounted under `/`. A **binary** is a compiled program you run (like `ls`). A **library** is reusable code that programs call (like `libc.so.6`).

---

## 22. Top Interview Questions (Quick Revision)

1. **`sudo` vs `su` vs `su -`?** One command as root / switch to root with old environment / switch to root with full root environment.
2. **`rm` vs `rmdir`?** `rm -r` deletes folder with contents. `rmdir` deletes only empty folders.
3. **`ls` vs `du`?** `ls` shows logical file size. `du` shows actual disk usage.
4. **Soft link vs hard link?** Soft has its own inode and breaks if the original is deleted. Hard shares the inode and survives deletion.
5. **`kill` vs `kill -9`?** SIGTERM (graceful) vs SIGKILL (force). Always try graceful first.
6. **`apt remove` vs `apt purge`?** Remove keeps config. Purge removes config too.
7. **`-G` vs `-aG` in `usermod`?** `-G` replaces groups. `-aG` appends. Always use `-aG`.
8. **What is `chmod 755`?** Owner rwx, group and others r-x.
9. **How to check which process uses a port?** `ss -tulpn \| grep <port>`.
10. **How to watch a log live?** `tail -f /var/log/<file>`.
11. **Why do most servers use Linux?** Stable, secure, fast, open source, free, automation friendly, and dominant in cloud.
12. **Cron vs crontab?** Cron is the service that runs jobs. Crontab is the file that lists them.

---

## 23. Quick Troubleshooting Flow

| Problem | Commands to run in order |
| --- | --- |
| Server slow | `uptime` → `top` → `free -h` → `df -h` |
| Disk full | `df -h` → `du -h --max-depth=1 /var` → `df -i` |
| Service down | `systemctl status` → `journalctl -u <svc>` → `ss -tulpn` |
| App not reachable | `ping` → `ip a` → `ss -tulpn` → `ufw status` → `curl localhost` |
| Permission denied | `ls -l` → `id` → `chmod` / `chown` |
| Cannot SSH | Check NSG port 22 → key permissions → `authorized_keys` format |
| Find errors in logs | `grep -i error /var/log/<file>` → `tail -f` |

---

## 24. Corrections Made and Gaps in Your Notes

Every correction made while building this guide is listed here, so you can compare it with your original files.

### A. Mistakes corrected

| # | Your file | Problem | Corrected in this guide |
| --- | --- | --- | --- |
| 1 | Users.docx | `cat /etc/groups` is the wrong file name | `cat /etc/group` |
| 2 | Linux Users and Groups.docx (summary table) | `usermod -aG <username> <groupname>` has the order reversed | `sudo usermod -aG <groupname> <username>` |
| 3 | Users.docx, step "Add Users to Group" | `usermod -g dev bharath` changes the **primary** group. It does not add a group | Shown as "Change primary group". Use `-aG` to add |
| 4 | Users.docx | Stray lines `useradd Bharath` (capital B) and `id devuser` (user never created) | Removed. Used `bharath` everywhere |
| 5 | Linux File commands.docx | `Echo “this is 2nd line” >> welcome.txt` uses capital E and curly quotes, so the shell fails | `echo "2nd line" >> welcome.txt` |
| 6 | Connecting to Linux Machine… and crontab.docx | Cron demo creates the script in `/home/azureuser`, but `chmod` and the output file use `/home/linuxuser` | All paths use `/home/azureuser` |
| 7 | Linux Day 3 Folder Structure….docx | `/bin` labelled "Common libraries" and `/sbin` labelled "Faculty" | `/bin` = essential commands, `/sbin` = admin commands, libraries are in `/lib` (section 21) |
| 8 | Linux Day 3 Folder Structure….docx | `/usr` explained as "Unix System Resources". This is a popular backronym. It originally meant "user" | Described by what it holds: installed applications and libraries |
| 9 | Linux File commands.docx | File starts with a chatbot sentence ("That's a great list of topics…") | Removed |
| 10 | Linux File commands detailed.docx | The mkdir section is garbled ("pw" and an empty-looking options table) | Rebuilt from your other notes (`mkdir`, `mkdir -p`). Please check the original file |

### B. Please verify on your VM

- After `sudo su`, `echo $HOME` shows `/home/azureuser` in your notes. Some Ubuntu versions show `/root` instead. The sure difference is that `sudo su -` always gives root's full login environment.
- Version numbers such as `nginx=1.18.0-0ubuntu1` depend on your Ubuntu release. Copy the exact string from `apt list -a nginx`.
- None of the commands were run on a real machine while preparing this guide.

### C. Added by me (not in your original notes)

- Warning to allow port 22 before `ufw enable`, and to open port 22 in the Azure NSG.
- Cron schedule examples (daily 2 AM, every 5 minutes, Monday 9:30 AM).
- `head -n`, `tail -n`, `chmod 600`, `chmod 400`, `chmod -R`, `du -ah | sort -h`, `df -Th`, `pkill`, `killall`, `ssh -i` examples.
- The troubleshooting flows (sections 23 and the "Troubleshooting" notes), the 12 interview questions, and the SSH error table.

### D. Topics not in your notes yet

Practise these next: `sed`, `awk`, `cut`, `sort`, `uniq`, `wc`, `xargs`, pipes and redirection (`2>&1`), environment variables (`export`, `env`, `PATH`), `lsof`, `nslookup` and `dig`, `traceroute`, `nc`, `visudo` and `/etc/sudoers`, systemd unit files, shell scripting basics, and `umask`.
