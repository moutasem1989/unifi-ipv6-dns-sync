# UniFi IPv6 DNS Sync

Automatically sync your server’s dynamic global IPv6 address with a UniFi Cloud Gateway local DNS record.

---

> ⚠️ **Warning**
>
> This script directly interacts with your UniFi Cloud Gateway via its API and updates DNS records.  
> Before using or installing this code:
>
> - Make sure you **understand what each part of the script does**.
> - Review the API requests and headers being sent to your gateway.
> - Ensure the IP address used in the script points to **your own local gateway**.
> - Only run this script on a **trusted and secure system**.
>
> 🛠️ This tool is provided **as-is** with **no warranty or guarantee**. Use it **at your own risk**.
>
> If you're unsure what the script is doing or how it affects your network, **do not proceed without further research**.

---

## ✨ Features

- Detects current SLAAC-assigned IPv6 address on Client
- Compares it to an existing UniFi local DNS record
- Automatically updates the DNS record using UniFi API
- Runs hourly via systemd timer

## 📦 Installation

### 1. Copy Script

```bash
sudo cp sync_ipv6_dns.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/sync_ipv6_dns.sh
```

### 2. Install systemd service and timer

```bash
sudo cp sync-ipv6-dns.service /etc/systemd/system/
sudo cp sync-ipv6-dns.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now sync-ipv6-dns.timer
```

## ⚙️ Configuration

Edit `sync_ipv6_dns.sh` and update:

- `API_KEY` – your UniFi gateway API key
- `RECORD_ID` – your DNS record ID (try inspecting the UniFi DNS Records page and check Network traffic for response to get the ID of all DNS Records)
- `RECORD_KEY` – the domain name (e.g. `awesomehomeserver.dlt`)

## 📜 Logs

```bash
journalctl -u sync-ipv6-dns.service
```

## 📝 License

MIT
