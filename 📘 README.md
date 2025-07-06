# setupprx

Script tự động cài proxy SOCKS5 bằng Dante trên Ubuntu.

## 🔧 Tính năng
- Cài đặt dante-server
- Tạo proxy SOCKS5 với:
  - Port random
  - Username/password random
- Ghi thông tin ra `/etc/proxy_info.txt`
- Tự động bật service sau khi cài đặt

## 🚀 Hướng dẫn sử dụng

```bash
curl -O https://raw.githubusercontent.com/Phamgioi993/setupprx/main/install_proxy_random.sh
chmod +x install_proxy_random.sh
sudo ./install_proxy_random.sh

# Xem thông tin proxy:
cat /etc/proxy_info.txt
