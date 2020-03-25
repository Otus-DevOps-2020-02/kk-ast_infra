#!/bin/bash
touch /etc/systemd/system/puma.service
chmod 644 /etc/systemd/system/puma.service
cat << EOF > /etc/systemd/system/puma.service
[Unit]
Description=puma server
After=network.target

[Service]
ExecStart=/usr/local/bin/puma -d
Type=forking

[Install]
WantedBy=default.target
EOF
systemctl daemon-reload
systemctl unmask puma.service
systemctl enable --now puma.service
