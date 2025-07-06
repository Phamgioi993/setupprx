#!/bin/bash

# Cập nhật và cài đặt Dante SOCKS5
apt update && apt install -y dante-server apache2-utils

# Random port từ 2000–65000
PORT=$(shuf -i 2000-65000 -n 1)
USERNAME="user$(tr -dc A-Za-z0-9 </dev/urandom | head -c 5)"
PASSWORD="pass$(tr -dc A-Za-z0-9 </dev/urandom | head -c 8)"

# Ghi thông tin user vào file auth
htpasswd -bc /etc/socksauth $USERNAME $PASSWORD

# Lấy interface tự động
IFACE=$(ip route get 1.1.1.1 | grep -oP 'dev \K\S+')

# Ghi file cấu hình danted
cat <<EOF > /etc/danted.conf
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

# Cấp quyền và khởi động lại
systemctl enable danted
systemctl restart danted

# Lưu thông tin
EXTERNAL_IP=$(curl -s ifconfig.me)
echo -e "IP: $EXTERNAL_IP\nPort: $PORT\nUsername: $USERNAME\nPassword: $PASSWORD" | tee /etc/proxy_info.txt
