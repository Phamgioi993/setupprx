#!/bin/bash

# Cài đặt Dante server
apt update && apt install -y dante-server pwgen

# Số lượng proxy cần tạo
NUM_PROXIES=5

# Giao diện mạng (network interface)
IFACE=$(ip route | grep default | awk '{print $5}')

# Khởi tạo file config
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: $IFACE port = 1025-65535
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

# Tạo từng user/password/port
for ((i=1; i<=NUM_PROXIES; i++)); do
    USERNAME="user$(pwgen -A0 4 1)"
    PASSWORD=$(pwgen 8 1)
    PORT=$((RANDOM % 10000 + 20000))

    # Tạo user
    useradd --shell /usr/sbin/nologin "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd

    # Ghi thông tin ra file
    IP=$(curl -s ifconfig.me)
    echo "$IP:$PORT:$USERNAME:$PASSWORD" >> /etc/proxy_list.txt

    # Thêm port vào range config
    echo "internal: $IFACE port = $PORT" >> /etc/danted.conf
done

# Khởi động lại dante
systemctl enable danted
systemctl restart danted

echo "✅ Hoàn tất! Proxy được lưu trong: /etc/proxy_list.txt"
cat /etc/proxy_list.txt
