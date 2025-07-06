#!/usr/bin/env bash
set -euo pipefail
# Cài đặt dante
apt update
apt install -y dante-server apache2-utils

# Random port, username, password
PORT=$(shuf -i 2000-65000 -n 1)
USERNAME="user$(tr -dc A-Za-z0-9 </dev/urandom | head -c5)"
PASSWORD="pass$(tr -dc A-Za-z0-9 </dev/urandom | head -c8)"

# Ghi vào file /etc/socksauth
htpasswd -bc /etc/socksauth $USERNAME $PASSWORD

# Lấy interface mặc định
IFACE=$(ip route get 1.1.1.1 | grep -oP 'dev \K\S+')

# Viết cấu hình Dante
cat <<EOF >/etc/danted.conf
logoutput: /var/log/danted.log
internal: $IFACE port = $PORT
external: $IFACE

method: username
user.notprivileged: nobody

client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect disconnect
}

socks pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: connect disconnect
  method: username
}
EOF

# Enable & restart dịch vụ
systemctl enable danted
systemctl restart danted

# Lưu thông tin proxy
EXTERNAL_IP=$(curl -s ifconfig.me)
echo -e "IP: $EXTERNAL_IP\nPort: $PORT\nUsername: $USERNAME\nPassword: $PASSWORD" | tee /etc/proxy_info.txt
