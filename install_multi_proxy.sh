#!/bin/bash

# Cài đặt dante-server nếu chưa có
apt update && apt install -y dante-server pwgen

# Số lượng proxy muốn tạo
NUM_PROXIES=5

# Lấy interface (tự động)
IFACE=$(ip route | grep default | awk '{print $5}')

# Tạo file cấu hình cơ bản
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: $IFACE port = 0
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

# Xoá file info cũ nếu có
rm -f /etc/proxy_list.txt

# Tạo từng proxy
for ((i=1; i<=NUM_PROXIES; i++)); do
    USERNAME="user$(pwgen -A0 4 1)"
    PASSWORD=$(pwgen 8 1)
    PORT=$((RANDOM % 10000 + 20000))

    useradd --shell /usr/sbin/nologin "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd

    echo "internal: $IFACE port = $PORT" >> /etc/danted.conf

    IP=$(curl -s ifconfig.me)
    echo "$IP:$PORT:$USERNAME:$PASSWORD" >> /etc/proxy_list.txt
done

# Khởi động lại danted
systemctl enable danted
systemctl restart danted

echo -e "✅ Hoàn tất! Proxy đã được lưu trong: /etc/proxy_list.txt"
cat /etc/proxy_list.txt
