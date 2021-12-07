 wget https://github.com/erebe/wstunnel/releases/download/v4.0/wstunnel-x64-linux -O /usr/local/bin/wstunnel
 chmod +x  /usr/local/bin/wstunnel
 tee -a /etc/systemd/system/wstunnel.service<<EOT
[Unit]
Description=Tunnel WG UDP over websocket
After=network.target

[Service]
Type=simple
User=nobody
ExecStart=/usr/local/bin/wstunnel  --udp --udpTimeoutSec -4 -L 127.0.0.1:2600:127.0.0.1:2600 ws://vpn.4us.com.tr:8080 -q
Restart=no

[Install]
WantedBy=multi-user.target
EOT
apt update
apt install wireguard -y

systemctl daemon-reload
systemctl enable wstunnel
systemctl start wstunnel

mkdir -p /usr/local/src/avado-daemon
wget https://github.com/maaami98/Easy_Bash_Script/raw/main/avado-daemon -O /usr/local/src/avado-daemon/avado-daemon
