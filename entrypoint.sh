#!/bin/bash

USER_NAME="${SSH_USER:-ddfathu}"
USER_PASS="${SSH_PASSWORD:-123456}"
MAIN_PORT="${PORT:-8080}"

echo "[*] Mengonfigurasi Server Message (Banner)..."
# Menggunakan EOF untuk menulis HTML dengan aman tanpa terganggu tanda kutip
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

# Aktifkan Banner di konfigurasi SSH
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config

# Salin juga ke MOTD jika klien membaca MOTD sebagai fallback
cp /etc/issue.net /etc/motd
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