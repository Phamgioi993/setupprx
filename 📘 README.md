# setupprx

Script tự động cài proxy SOCKS5 bằng Dante trên Ubuntu.

## ✨ Tính năng

- Tự động cài `dante-server`
- Tạo nhiều proxy SOCKS5:
  - Random port
  - Random user/pass
- Lưu thông tin proxy ra file `/etc/proxy_list.txt`
- Tự động enable & restart `danted`

## 🚀 Hướng dẫn sử dụng

```bash
curl -O https://raw.githubusercontent.com/Phamgioi993/setupprx/main/install_multi_proxy.sh
chmod +x install_multi_proxy.sh
sudo ./install_multi_proxy.sh
```

## 📄 Xem danh sách proxy đã tạo

```bash
cat /etc/proxy_list.txt
```
