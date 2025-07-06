#!/bin/bash

# === Cap nhat va cai goi can thiet ===
apt update -y && apt install -y dante-server curl net-tools whois

# === Tao port, user, pass ngau nhien ===
PORT=$(shuf -i 20000-30000 -n 1)
USERNAME="user$(shuf -i 1000-9999 -n 1)"
PASSWORD="pass$(mkpasswd -l 12)"

# === Ghi file xac thuc SOCKS ===
echo -e "$USERNAME $PASSWORD" > /etc/socksauth
chmod 600 /etc/socksauth

# === Lay interface mang (vi du: ens4 hoac eth0) ===
IFACE=$(ip route get 8.8.8.8 | grep -oP 'dev \K\w+')

# === Ghi file cau hinh Dante ===
cat <<EOF > /etc/danted.conf
logoutput: syslog
internal: $IFACE port = $PORT
external: $IFACE

socksmethod: username
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

# === Ghi firewall mo cong tuong ung ===
gcloud compute firewall-rules create allow-socks5-$PORT \
  --allow=tcp:$PORT \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --target-tags=socks-proxy \
  --source-ranges=0.0.0.0/0

# === Ghi tag vao instance VM hien tai ===
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/name)
ZONE=$(curl -s -H "Metadata-Flavor: Google" \
  http://metadata.google.internal/computeMetadata/v1/instance/zone | awk -F/ '{print $NF}')

gcloud compute instances add-tags "$INSTANCE_NAME" \
  --zone="$ZONE" \
  --tags=socks-proxy

# === Kich hoat va khoi dong lai dich vu ===
systemctl enable danted
systemctl restart danted

# === In ra thong tin proxy ===
IP=$(curl -s ifconfig.me)
echo "=============================="
echo " SOCKS5 Proxy Da Cai Dat!"
echo "=============================="
echo "IP: $IP"
echo "Port: $PORT"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "=============================="
echo "" > /etc/proxy_info.txt
echo "socks5://$USERNAME:$PASSWORD@$IP:$PORT" | tee /etc/proxy_info.txt
