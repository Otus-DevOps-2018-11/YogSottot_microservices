#!/usr/bin/env bash
set -e

db_ip=$1

APP_DIR=$HOME

git clone -b monolith https://github.com/express42/reddit.git $APP_DIR/reddit
cd $APP_DIR/reddit
bundle install

echo "export DATABASE_URL=${db_ip}" >> /home/appuser/.bash_profile

sudo mv /tmp/puma.service /etc/systemd/system/puma.service
sudo systemctl start puma
sudo systemctl enable puma
