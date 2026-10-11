## SCP, Rsync, Rclone & Netcat — File Transfer Notes
---
## 1. SCP (Secure Copy)

```bash
scp <source> <destination>
```

```bash
# Local -> Remote
scp file.txt user@host:/remote/path/

# Remote -> Local
scp user@host:/remote/path/file.txt ./

# Whole directory
scp -r localdir/ user@host:/remote/path/

# Non-default SSH port
scp -P 2222 file.txt user@host:/remote/path/

# Between TWO remote servers, without downloading locally first
scp user1@host1:/path/file.txt user2@host2:/path/
```

```bash
scp user@IPaddr <source> <destination>

SOURCE      = ubuntu@10.0.0.5:/tmp/test.txt
DESTINATION = .
```

| Flag | Meaning |
|------|---------|
| `-r` | recursive, needed for directories |
| `-P` | port (capital `P` — lowercase `-p` means something else: preserve timestamps) |
| `-p` | preserve modification times/permissions |
| `-C` | compress during transfer (helps over slow links) |

**Limitation worth knowing:** `scp` always copies the whole file, every time. Copy a 10GB file, change one line, copy again — it re-sends all 10GB.

---

## 2. Rsync

`rsync` only transfers the differences between source and destination (**delta transfer**), and it can resume interrupted transfers.

```bash
rsync <source> <destination>
rsync -avz source/ user@host:/remote/path/
```

| Flag | Meaning |
|------|---------|
| `-a` | archive mode — preserves permissions, timestamps, symlinks, and recurses into directories (bundles several flags) |
| `-v` | verbose — see what's happening |
| `-z` | compress during transfer |
| `-P` | show progress AND allow resuming a partial transfer (combines `--progress` + `--partial`) |
| `--delete` | delete files in destination that no longer exist in source (makes destination an exact mirror — use carefully) |
| `-n` | dry run — show what WOULD happen without doing it (always test with this first for anything with `--delete`) |

```bash
rsync -avzP source/ user@host:/remote/path/               # with progress + resume
rsync -avz --delete -n source/ user@host:/remote/path/    # dry-run a mirror sync first
```

### Trailing slash matters

```bash
rsync -av source/ dest/    # copies CONTENTS of source into dest
```
Meaning: copies all the files inside `source/` into `dest/`.

```bash
rsync -av source dest/     # copies source folder ITSELF into dest (dest/source/...)
```
Meaning: copies the `source` directory itself into `dest/`, nested one level deeper.

```bash
rsync -avz /local/path/ user@host:/remote/path/    # local -> remote
rsync -avz user@host:/remote/path/ /local/path/    # remote -> local (just flip source/dest)
```

---

## 3. Rclone

`rclone` is essentially `rsync` for cloud storage.

```bash
rclone config
rclone listremotes                                     # see configured remotes
rclone ls mys3:my-bucket-name                           # list what's in a bucket
rclone copy /local/path/ mys3:my-bucket-name/path/      # local -> cloud
rclone copy mys3:my-bucket-name/path/ /local/path/      # cloud -> local
rclone sync /local/path/ mys3:my-bucket-name/path/      # like rsync --delete, makes them match exactly
```

**Key distinction:** `rclone copy` adds/updates files but never deletes; `rclone sync` makes the destination an exact mirror of the source (deletes extras in the destination) — same caution as `rsync --delete`, dry-run first:

```bash
rclone sync /local/path/ mys3:bucket/path/ --dry-run
```

---

## 4. Netcat (`nc`) + `tar` — the "skip all the overhead" trick

**Local server to local server (two machines on the same LAN)**

```bash
# Everyday case: rsync over SSH (still encrypted, still safe default)
rsync -avzP /local/path/ user@other-local-ip:/remote/path/
```

```bash
# If it's a trusted internal network and raw speed really matters:
# (receiving machine) nc -l -p 9999 | tar -xvf -
# (sending machine)   tar -cvf - /path | nc other-ip 9999
```

This `nc` + `tar` combo is the fastest option, specifically because it skips SSH's encryption/authentication overhead entirely — which is exactly why it's only appropriate on a trusted local/private network (e.g., two servers in the same datacenter/VPC), **never** over the public internet.

**Local server to remote server (over the internet)**

```bash
scp -r file_or_dir user@remote-ip:/path/           # one-off
rsync -avzP file_or_dir/ user@remote-ip:/path/     # recurring/large — always prefer this
```
