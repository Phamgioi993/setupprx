# SOCKS5 Proxy Auto Installer (with random port & credentials)

This script automatically installs a SOCKS5 proxy using Dante on Ubuntu (Google Cloud or any VPS).

It includes:
- ✅ Automatic random **port**
- ✅ Automatic random **username/password**
- ✅ Automatic firewall configuration (for GCP)
- ✅ Auto interface detection
- ✅ Log handling
- ✅ Robust error-avoidance

---

## 🚀 How to use

```bash
curl -O https://yourdomain.com/install_proxy_random.sh
chmod +x install_proxy_random.sh
sudo ./install_proxy_random.sh
```

---

## 🔒 What gets created

- A SOCKS5 proxy on a **random port** (between 10000-20000)
- Random username and password generated on install
- Firewall port opened (on GCP via `gcloud` CLI)
- Dante SOCKS5 service running and enabled

---

## ✅ Improvements included

- Detects real network interface (not hardcoded `eth0`)
- Fixes logging issues on systems with read-only `/var/log`
- Avoids systemd errors by declaring unit properly
- Prevents restart crash via `Restart=on-failure`
- Minimal footprint (only installs what's needed)

---

## 🔁 Example output

```
IP: 35.xxx.xxx.xxx
Port: 10123
Username: abcd1234
Password: xYz98765
```

---

## ⚠️ Requirements

- Ubuntu 20.04 or 22.04
- Root access
- For GCP: gcloud CLI must be available in environment

---

**Created by: You**  
