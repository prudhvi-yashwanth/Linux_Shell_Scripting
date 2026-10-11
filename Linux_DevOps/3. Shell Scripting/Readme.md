# 📊 Auto Log Monitor Script

A Bash script that monitors `.log` files modified in the last 24 hours under `/var/log`, scans them for critical error patterns, and sends alert emails to the DevOps team if the number of occurrences exceeds a defined threshold.

---

## 🛠 Features

- ✅ Scans recently modified log files (`*.log`) in `/var/log`
- 🔍 Detects common error patterns: `ERROR`, `CRITICAL`, `FAILURE`, `FATAL`, `EXCEPTION`
- 📧 Sends alert emails when error count exceeds threshold
- 📁 Generates timestamped monitoring reports in `/var/log/log-monitor`
- 🧱 Robust error handling with `set -euo pipefail`
- 🕵️‍♂️ Easy to schedule via cron or systemd

---

## 📂 Directory Structure

```
/var/log/log-monitor/
└── auto_log_monitor_<timestamp>.log   # Monitoring report
```

---

## ⚙️ Configuration

You can customize the following variables inside the script:

```bash
LOG_DIR="/var/log/log-monitor"         # Where reports are saved
ALERT_THRESHOLD=10                     # Error count threshold
EMAIL_RECIPIENT="xxxxxx@gmail.com"     # Alert recipient
ERROR_PATTERN=("ERROR" "CRITICAL" ...) # Keywords to scan
```

---

## 🚀 Usage

### 1. Make the script executable

```bash
chmod +x auto_log_monitor.sh
```

### 2. Run manually

```bash
./auto_log_monitor.sh
```

### 3. Schedule via cron (daily at 9 PM)

```bash
crontab -e
```

Add:

```bash
0 21 * * * /path/to/auto_log_monitor.sh
```

---

## 📬 Email Alerts

If any log file contains more than `ALERT_THRESHOLD` occurrences of a defined error pattern, an email is sent to the configured recipient using the `mail` command.

> **Note**: Ensure `mailutils` or `sendmail` is installed and configured on your system.

---

## 🧪 Sample Output

```
=== Log Files Monitoring Report ===
Generated on: Sun Oct 12 21:00:01 IST 2025
========================================================
Monitoring log files modified in the last 24 hours...
/var/log/syslog
/var/log/nginx/error.log

Checking file: /var/log/nginx/error.log
Total 'ERROR' occurrences: 12
⚠️ Alert: 'ERROR' occurrences exceeded threshold.
Sending alert email to xxxxxx@gmail.com...
```

---

## 🧰 Dependencies

- Bash (v4+ recommended)
- `mail` or `sendmail` for email alerts
- Access to `/var/log` (requires sudo if restricted)

---

## 🧼 Best Practices

- Use `set -euo pipefail` for safe scripting
- Rotate logs in `/var/log/log-monitor` periodically
- Validate email delivery with test alerts
- Consider integrating with centralized logging (e.g., ELK, Prometheus) for scale

---

## 📌 Future Enhancements

- [ ] Add CLI flags for threshold, patterns, and log path
- [ ] Support JSON or HTML report output
- [ ] Slack or webhook integration for alerts
- [ ] Dockerize for portability

---

## 📄 License

MIT License  
© 2025 Prudhvi Yashwanth Reddy Kikkuru

---

## 👨‍💻 Author

**Prudhvi Yashwanth Reddy Kikkuru**  
DevOps Engineer, TCS  
Currently exploring advanced DevOps practices and Python automation

---
