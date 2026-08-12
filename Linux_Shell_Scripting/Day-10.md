# Linux - Day 10: `systemctl` and `journalctl`

## Overview

Today we are learning how to manage Linux services and view their logs using:

- `systemctl`
- `journalctl`

These commands are commonly used by DevOps Engineers for:

- Starting and stopping services
- Checking service status
- Restarting or reloading services
- Enabling services at boot
- Troubleshooting service failures
- Checking service logs

---

# `systemctl`

`systemctl` is used to manage services controlled by **systemd**.

Common services include:

- Nginx
- Docker
- SSH
- Kubernetes services
- Application services

---

# 1. Check Service Status

```bash
sudo systemctl status <service-name>
```

Example:

```bash
sudo systemctl status nginx
```

This shows information such as:

- Whether the service is running
- Service PID
- Recent logs
- Whether the service is enabled
- Recent service errors

Example:

```text
● nginx.service - A high performance web server
     Loaded: loaded
     Active: active (running)
```

---

# 2. Install Nginx

On Ubuntu:

```bash
sudo apt update
sudo apt install -y nginx
```

The `-y` option automatically answers `yes` to installation prompts.

---

# 3. Start a Service

```bash
sudo systemctl start <service-name>
```

Example:

```bash
sudo systemctl start nginx
```

This starts the service if it is not already running.

---

# 4. Check the Service Again

```bash
sudo systemctl status nginx
```

You should see:

```text
Active: active (running)
```

---

# 5. Restart a Service

```bash
sudo systemctl restart <service-name>
```

Example:

```bash
sudo systemctl restart nginx
```

`restart` stops the service and starts it again.

This causes the service process to restart and may cause a brief interruption.

---

# 6. Reload a Service

```bash
sudo systemctl reload <service-name>
```

A **reload** tells the service to reload its configuration without completely stopping the service.

Example:

```bash
sudo systemctl reload nginx
```

Not every service supports reload.

---

# Restart vs Reload

Suppose you changed the Nginx configuration.

### Preferred approach

If the service supports reload:

```bash
sudo systemctl reload nginx
```

This applies the new configuration while keeping the existing service process running.

### Restart

```bash
sudo systemctl restart nginx
```

This completely restarts the service.

---

## Best Practice

For production systems:

```text
Configuration Change
        │
        ▼
Test Configuration
        │
        ▼
Reload if Supported
        │
        └── Otherwise → Restart
```

Use **reload** when supported and when the configuration change can be applied safely without restarting the service.

> **Important:** Reload behaviour depends on the service. Always confirm that the service supports reload and understand how it handles configuration changes.

---

# 7. Enable a Service

```bash
sudo systemctl enable <service-name>
```

Example:

```bash
sudo systemctl enable nginx
```

This configures the service to start automatically during system boot.

---

# 8. Disable a Service

```bash
sudo systemctl disable <service-name>
```

Example:

```bash
sudo systemctl disable nginx
```

This prevents the service from being automatically started during boot.

> **Important:** `disable` does not normally stop a service that is already running. To stop it immediately, use:
>
> ```bash
> sudo systemctl stop nginx
> ```

---

# 9. Check if a Service is Active

```bash
systemctl is-active <service-name>
```

Example:

```bash
systemctl is-active nginx
```

Possible output:

```text
active
```

or:

```text
inactive
```

This is useful in automation and shell scripts.

Example:

```bash
while ! systemctl is-active --quiet nginx; do
    echo "Waiting for nginx..."
    sleep 2
done
```

---

# Common `systemctl` Commands

| Command | Purpose |
|---------|---------|
| `systemctl status SERVICE` | View service status |
| `systemctl start SERVICE` | Start the service |
| `systemctl stop SERVICE` | Stop the service |
| `systemctl restart SERVICE` | Restart the service |
| `systemctl reload SERVICE` | Reload configuration |
| `systemctl enable SERVICE` | Start service automatically at boot |
| `systemctl disable SERVICE` | Prevent automatic startup at boot |
| `systemctl is-active SERVICE` | Quickly check whether the service is active |
| `systemctl is-enabled SERVICE` | Check whether the service is enabled at boot |

---

# `journalctl`

`journalctl` is used to read logs stored in the **systemd journal**.

It is especially useful for troubleshooting services managed by `systemd`.

---

# 1. View Nginx Logs

```bash
journalctl -u nginx
```

The `-u` option filters the logs for a specific systemd unit.

Here:

```text
-u nginx
```

means:

> Show logs for the Nginx service.

---

# 2. View Recent Logs

```bash
journalctl -u nginx --since "10 minutes ago"
```

This shows Nginx logs generated during the last 10 minutes.

Other examples:

```bash
journalctl -u nginx --since "1 hour ago"
```

```bash
journalctl -u nginx --since "2026-08-12 09:00:00"
```

---

# 3. Follow Logs in Real Time

```bash
journalctl -u nginx -f
```

The `-f` option follows new log entries as they are generated.

This is useful when troubleshooting a running service.

Press:

```text
Ctrl + C
```

to stop following the logs.

---

# 4. View Recent Logs with Extra Information

```bash
journalctl -u nginx -xe
```

Options:

- `-x` → Adds explanatory information where available.
- `-e` → Jumps to the end of the journal, showing the newest entries.

This is useful when a service has recently failed.

---

# Troubleshooting Scenario

Suppose you changed the Nginx configuration and restarted the service:

```bash
sudo systemctl restart nginx
```

but the service failed.

Check the status:

```bash
sudo systemctl status nginx
```

Then check the logs:

```bash
journalctl -u nginx -xe
```

The logs may indicate the configuration or startup error.

---

# Why `nginx -t` Matters

Before reloading or restarting Nginx after changing its configuration, test the configuration first.

```bash
sudo nginx -t
```

A successful result looks similar to:

```text
syntax is ok
test is successful
```

Only after the configuration test succeeds should you reload Nginx:

```bash
sudo systemctl reload nginx
```

---

# Production Best Practice

A safer workflow is:

```text
Modify Configuration
        │
        ▼
Test Configuration
        │
        │ nginx -t
        ▼
Is Configuration Valid?
      │        │
     No       Yes
      │        │
      ▼        ▼
Fix Config   Reload
               │
               ▼
        Verify Service
```

Example:

```bash
sudo nginx -t
sudo systemctl reload nginx
sudo systemctl status nginx
```

If the configuration test fails:

```text
Do NOT reload/restart
```

First fix the configuration.

---

# Why This Is Important

Suppose Nginx is already working:

```text
Nginx
  │
  ▼
Serving Production Traffic
```

You make a configuration mistake and immediately run:

```bash
sudo systemctl restart nginx
```

Nginx may fail to start because of the invalid configuration.

This can cause an unnecessary production outage.

Instead:

```bash
sudo nginx -t
```

If the configuration is invalid, fix it before changing the running service.

---

# General Configuration Testing

Nginx is one example.

Many services provide their own configuration-test command, such as:

```text
-t
--test
configtest
```

The exact command depends on the service.

The general principle is:

> **Validate configuration before reloading or restarting a production service whenever the application provides a configuration-testing command.**

---

# `systemctl` + `journalctl` Troubleshooting Flow

When a service is not working:

```text
Service Problem
      │
      ▼
systemctl status SERVICE
      │
      ▼
Is the service running?
   │              │
  Yes             No
   │              │
   ▼              ▼
Check logs    journalctl -u SERVICE -xe
   │              │
   └──────┬───────┘
          ▼
      Identify Error
          │
          ▼
    Fix the Problem
          │
          ▼
    Test Configuration
          │
          ▼
       Reload
          │
          ▼
   Verify Service Status
```

---

# Example: Nginx Troubleshooting

```bash
# Check service status
sudo systemctl status nginx

# Check recent logs
journalctl -u nginx --since "10 minutes ago"

# Test configuration
sudo nginx -t

# Reload if the configuration is valid
sudo systemctl reload nginx

# Verify the service
sudo systemctl status nginx
```

---

# Important Difference

### `systemctl`

Used to **manage services**.

```text
Start
Stop
Restart
Reload
Enable
Disable
Check status
```

### `journalctl`

Used to **read logs**.

```text
View logs
Filter by service
Filter by time
Follow logs
View errors
```

---

# Quick Revision

```text
systemctl
    → Manage services

systemctl status nginx
    → Check service status

systemctl start nginx
    → Start service

systemctl restart nginx
    → Restart service

systemctl reload nginx
    → Reload configuration without a full restart

systemctl enable nginx
    → Start automatically at boot

systemctl is-active nginx
    → Check whether service is active

journalctl -u nginx
    → View Nginx logs

journalctl -u nginx --since "10 minutes ago"
    → View recent Nginx logs

journalctl -u nginx -f
    → Follow Nginx logs in real time

journalctl -u nginx -xe
    → View recent logs with extra information
```

---

# Interview Answer

> **"`systemctl` is used to manage systemd services, while `journalctl` is used to view their logs. For example, I use `systemctl status nginx` to check the service status, `systemctl start` or `restart` to manage the service, and `systemctl reload` when I want to apply configuration changes without a full restart, provided the service supports reload. For troubleshooting, I use `journalctl -u nginx -xe` to check recent logs and identify the problem. Before reloading Nginx after a configuration change, I use `nginx -t` to validate the configuration and avoid taking a working service down with an invalid configuration."**
