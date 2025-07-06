#!/bin/bash

# Cập nhật & cài gói
apt update -y && apt install -y dante-server whois curl

# Random user/pass/port
PORT=$(shuf -i 20000-55000 -n 1)
USERNAME="user$(shuf -i 1000-9999 -n 1)"
PASSWORD="pass$(mkpasswd -l 12)"

# Ghi file auth
cat <<EOF > /etc/socksauth
$USERNAME $PASSWORD
EOF
chmod 600 /etc/socksauth

# Lấy interface của VM (tìm thấy ens4 hoặc en0)
IFACE=$(ip route get 8.8.8.8 | grep -oP 'dev \K\S+')

# Ghi file config danted
cat <<EOF > /etc/danted.conf
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
  socksmethod: username
}
EOF

# Ghi file /etc/default/danted (nếu Ubuntu)
echo 'OPTIONS=""' > /etc/default/danted

# Mở port trong firewall (nếu chơi GCP)
gcloud compute firewall-rules create "allow-socks5-$PORT" \
  --allow=tcp:$PORT \
  --direction=INGRESS \
  --priority=1000 \
  --network=default \
  --target-tags=proxy \
  --source-ranges=0.0.0.0/0 || true

# Gắn tag cho VM
INSTANCE_NAME=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/name)
ZONE=$(curl -s -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d/ -f4)
gcloud compute instances add-tags "$INSTANCE_NAME" \
  --tags=proxy \
  --zone=$ZONE || true

# Bật và restart Dante
systemctl enable danted
systemctl restart danted

# Lưu thông tin proxy
EXTERNAL_IP=$(curl -s ifconfig.me)
echo "IP: $EXTERNAL_IP:$PORT | User: $USERNAME | Pass: $PASSWORD" | tee /etc/proxy_info.txt

# In thông tin ra màn hình
echo "\nProxy SOCKS5 đã hoạt động:"
echo "IP: $EXTERNAL_IP"
echo "Port: $PORT"
echo "User: $USERNAME"
echo "Pass: $PASSWORD"
echo "\nLưu tại /etc/proxy_info.txt"
