#!/bin/bash
set -e

APP_DIR="/opt"

sudo git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install

sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl daemon-reload
sudo systemctl unmask puma
sudo systemctl enable --now puma
