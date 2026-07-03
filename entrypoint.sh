#!/bin/bash

# Mengambil environment variables atau menggunakan nilai default
USER_NAME="${SSH_USER:-j1btnl}"
USER_PASS="${SSH_PASSWORD:-j1btnl}"
MAIN_PORT="${PORT:-8080}"

echo "[*] Mengonfigurasi Server Message (Banner & MOTD)..."
# 1. Menulis pesan HTML menggunakan EOF agar aman dari tanda kutip
cat << 'EOF' > /etc/issue.net
<p style="text-align:center">
<font color='#FF0059'>▬</font><font color='#F1006F'>▬</font><font color='#E30085'>▬</font>
<font color="#F5FE00"><b> --- ۩ PREMIUM SSH ۩ --- </b></font><br>
<font color='red'>!!! TERM OF SERVICE !!!</font><br>
<font color='#20CDCC'><b>         NO SPAM           </b></font><br>
<font color='#10C7E5'><b>         NO DDOS           </b></font><br>
<font color='#00C1FF'><b>  NO HACKING AND CARDING   </b></font><br>
<font color="#E51369"><b>    Multi Login BANNED!!     </b></font><br>
<font color='red'><b> Server VPS Auto Reboot On 05.00 GMT +7 </b></font><br>
<font color="#556B2F"><b>JIBSZZ SERVER</b></font><br>
<font color='#FF0059'>▬</font><font color='#F1006F'>▬</font><font color='#E30085'>▬</font>
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