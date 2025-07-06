#!/bin/bash

# Cập nhật và cài đặt dante-server
apt update && apt install -y dante-server

# Random username, password, port
USERNAME="user$(openssl rand -hex 2)"
PASSWORD="pass$(openssl rand -hex 4)"
PORT=$((RANDOM % 40000 + 1025))

# Giao diện mạng (interface)
IFACE=$(ip route | grep default | awk '{print $5}')

# Tạo file cấu hình Dante
cat > /etc/danted.conf <<EOF
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
  command: connect
  log: connect disconnect
  method: username
}
EOF

# Tạo user proxy
useradd --shell /usr/sbin/nologin $USERNAME
echo "$USERNAME:$PASSWORD" | chpasswd

# Bật và khởi động lại service
systemctl enable danted
systemctl restart danted

# Lưu thông tin
IP=$(curl -s ifconfig.me)
echo -e "IP: $IP\nPort: $PORT\nUsername: $USERNAME\nPassword: $PASSWORD" | tee /etc/proxy_info.txt

echo "✅ Proxy đã sẵn sàng!"
