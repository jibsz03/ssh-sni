#!/bin/bash

# Mengambil environment variables atau menggunakan nilai default
USER_NAME="${SSH_USER:-j1btnl}"
USER_PASS="${SSH_PASSWORD:-j1btnl}"
MAIN_PORT="${PORT:-8080}"

echo "[*] Mengonfigurasi Server Message (Banner Pra-Login)..."
cat << 'EOF' > /etc/issue.net
<p align="center">
<font color="#FF00A0">❖═════════════════════════════════❖</font><br>
<font color="#00FFFF"><b>✦ WELCOME TO JIBSZZ SERVER ✦</b></font><br>
<font color="#FF00A0">❖═════════════════════════════════❖</font><br>
<font color="#FFFF00"><b>⚙️ SERVER TERMS OF SERVICE ⚙️</b></font><br>
<br>
<font color="#FF3333"><b>⚠️ STRICTLY PROHIBITED ⚠️</b></font><br>
<font color="#FFFFFF">❌ NO SPAM / HACKING / CARDING</font><br>
<font color="#FFFFFF">❌ NO DDOS & TORRENTING</font><br>
<br>
<font color="#00FF00"><b>ℹ️ SERVER NOTICES ℹ️</b></font><br>
<font color="#00FFFF">⚡ High Speed Connection ⚡</font><br>
<br>
<font color="#FF00A0">❖═════════════════════════════════❖</font><br>
<font color="#FFFF00"><b>§ ENJOY YOUR SSH ACCOUNT §</b></font><br>
<font color="#FF00A0">❖═════════════════════════════════❖</font>
</p>
EOF

echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
sed -i 's/PrintMotd no/PrintMotd yes/g' /etc/ssh/sshd_config
rm -f /etc/update-motd.d/*
cp /etc/issue.net /etc/motd

echo "[*] Mengonfigurasi Respon Server (Pasca-Login)..."
# Skrip ini akan dieksekusi otomatis ketika user berhasil login
cat << 'EOF' > /etc/profile.d/99-respon-server.sh
#!/bin/bash
clear
echo -e "\e[1;36m=================================================\e[0m"
echo -e "\e[1;32m       [✓] BERHASIL TERHUBUNG KE SERVER!         \e[0m"
echo -e "\e[1;36m=================================================\e[0m"
echo -e "\e[1;37m Username     : \e[1;33m$USER\e[0m"
echo -e "\e[1;37m Waktu Server : \e[1;33m$(date)\e[0m"
echo -e "\e[1;37m OS           : \e[1;33mUbuntu 22.04 LTS\e[0m"
echo -e "\e[1;36m=================================================\e[0m"
echo -e "\e[1;31m   TETAP PATUHI RULES SERVER AGAR TIDAK BANNED   \e[0m"
echo -e "\e[1;36m=================================================\e[0m"
EOF
chmod +x /etc/profile.d/99-respon-server.sh

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