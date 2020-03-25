#!/bin/bash
# отсутствуют директория для запуска, проверка корректности установки, запуска
cd /opt
sudo git clone -b monolith https://github.com/express42/reddit.git
cd reddit && bundle install
puma -d
