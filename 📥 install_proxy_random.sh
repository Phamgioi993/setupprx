#!/bin/bash

# ===================== THIET LAP DAU =======================
set -e

# Cap nhat va cai dat
sudo apt update && sudo apt install -y dante-server whois curl net-tools

# Tao ngau nhien user/pass/port
PORT=$(shuf -i 20000-55000 -n 1)
USERNAME="user$(shuf -i 1000-9999 -n 1)"
PASSWORD="pass$(mkpasswd -l 12)"

# Luu file auth
sudo bash -c "echo -e '$USERNAME $PASSWORD' > /etc/socksauth"
sudo chmod 600 /etc/socksauth

# Lay interface VM (vd: ens4 hoac eth0)
IFACE=$(ip route get 8.8.8.8 | grep -oP 'dev \K\S+')

# Lay IP ben ngoai
EXTERNAL_IP=$(curl -s ipv4.icanhazip.com)

# Ghi file config Dante
sudo bash -c "cat > /etc/danted.conf" <<EOL
logoutput: /var/log/danted.log
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
EOL

# Tao file log & cap quyen
sudo touch /var/log/danted.log
sudo chmod 666 /var/log/danted.log

# Mo port tu dong bang firewall
echo "Dang tao firewall rule..."
gcloud compute firewall-rules create allow-socks5-$PORT \
  --allow=tcp:$PORT \
  --target-tags=socks5 \
  --description="Allow SOCKS5 proxy port $PORT" \
  --direction=INGRESS \
  --priority=1000

# Gan tag VM (yeu cau VM da bat full scope hoac dung Service Account)
INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
ZONE=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d'/' -f4)
gcloud compute instances add-tags "$INSTANCE_NAME" --zone "$ZONE" --tags socks5

# Enable & start Dante
sudo systemctl enable danted
sudo systemctl restart danted

# In thong tin proxy ra man hinh
echo -e "\n====== SOCKS5 Proxy Da Cai Dat! ======"
echo "IP: $EXTERNAL_IP"
echo "Port: $PORT"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "====================================="

# Luu file
sudo bash -c "echo '$EXTERNAL_IP:$PORT:$USERNAME:$PASSWORD' > /etc/proxy_info.txt"
