#!/bin/bash

# Cập nhật và cài đặt Dante server
apt update && apt install -y dante-server apache2-utils

# Tạo user
useradd -M -s /usr/sbin/nologin 82kJ99ME
echo "82kJ99ME:J1Z0g1sC" | chpasswd

# Cấu hình Dante
cat > /etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: ens4 port = 10123
external: ens4

method: username
user.privileged: root
user.unprivileged: nobody
user.libwrap: nobody

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    log: connect disconnect error
}

pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
    protocol: tcp udp
    method: username
    log: connect disconnect error
}
EOF

# Mở log
touch /var/log/danted.log
chmod 666 /var/log/danted.log

# Khởi động Dante
systemctl restart danted
systemctl enable danted

# Xuất thông tin proxy
echo "SOCKS5 Proxy đã được cài đặt thành công!"
echo "IP: $(curl -s ifconfig.me)"
echo "Port: 10123"
echo "Username: 82kJ99ME"
echo "Password: J1Z0g1sC"
