#!/bin/bash

USER_NAME="${SSH_USER:-ddfathu}"
USER_PASS="${SSH_PASSWORD:-123456}"
MAIN_PORT="${PORT:-8080}"

# 1. Mengonfigurasi Server Message
MESSAGE="${SERVER_MESSAGE:-Selamat datang di Server SSH J1BTNL!}"

echo "[*] Mengonfigurasi Server Message..."
# Menyimpan pesan untuk Banner (sebelum login)
echo -e "$MESSAGE\n" > /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# Menyimpan pesan untuk MOTD (setelah login)
echo -e "$MESSAGE\n" > /etc/motd
# Nonaktifkan default motd Ubuntu agar tidak menimpa pesan kustom
sed -i 's/PrintMotd no/PrintMotd yes/g' /etc/ssh/sshd_config
rm -f /etc/update-motd.d/*

echo "[*] Mengonfigurasi User SSH..."
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Memulai OpenSSH Server di Port 22..."
/usr/sbin/sshd

echo "[*] Membuat konfigurasi Stunnel tunggal di Port $MAIN_PORT..."
cat <<EOF > /etc/stunnel/stunnel.conf
pid = /var/run/stunnel.pid
foreground = yes
debug = 4

[ssh-ssl]
accept = 0.0.0.0:$MAIN_PORT
connect = 127.0.0.1:22
cert = /etc/stunnel/stunnel.pem
EOF

echo "[*] Memulai Stunnel..."
exec stunnel /etc/stunnel/stunnel.conf