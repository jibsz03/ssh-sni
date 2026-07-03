#!/bin/bash

# Mengambil environment variables atau menggunakan nilai default
USER_NAME="${SSH_USER:-j1btnl}"
USER_PASS="${SSH_PASSWORD:-j1btnl}"
MAIN_PORT="${PORT:-8080}"

echo "[*] Mengonfigurasi Server Message (Banner & MOTD)..."
# 1. Menulis pesan HTML menggunakan EOF agar aman dari tanda kutip
cat << 'EOF' > /etc/issue.net
<p align="center">
<font color='red'>◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣</font><br>
<font color="#00C1FF"><b>  ☣️ JIBSZZ SSH SERVER ☣️  </b></font><br>
<font color='red'>◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤</font><br>
<br>
<font color="#FFFF00"><b>▓▒░ CRITICAL RULES ░▒▓</b></font><br>
<font color="#FFFFFF">⚠️ <b>NO</b> SPAM / DDOS / TORRENT</font><br>
<font color="#FFFFFF">⚠️ <b>NO</b> CARDING & HACKING ACTIVITES</font><br>
<br>
<font color="#20CDCC"><b>[ SYSTEM STATUS ]</b></font><br>
<font color="#FFFFFF">Server Normal</font><br>
<br>
<font color='red'>◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣</font><br>
<font color="#FFFF00"><b>  DO WITH YOUR OWN RISK!  </b></font><br>
<font color='red'>◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤◢◣◥◤</font>
</p>
EOF

# 2. Mengaktifkan Banner (pesan sebelum koneksi) di konfigurasi SSH
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# 3. Mengatur MOTD (pesan setelah koneksi) dan menonaktifkan default Ubuntu
cp /etc/issue.net /etc/motd
sed -i 's/PrintMotd no/PrintMotd yes/g' /etc/ssh/sshd_config
rm -f /etc/update-motd.d/*

echo "[*] Mengonfigurasi User SSH..."
# Membuat user baru jika belum ada
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    usermod -aG sudo "$USER_NAME"
fi
# Mengatur password user
echo "$USER_NAME:$USER_PASS" | chpasswd

echo "[*] Memulai OpenSSH Server di Port 22..."
/usr/sbin/sshd

echo "[*] Membuat konfigurasi Stunnel tunggal di Port $MAIN_PORT..."
# Menulis konfigurasi untuk Stunnel
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
# Menjalankan Stunnel di *foreground* agar container tetap hidup
exec stunnel /etc/stunnel/stunnel.conf