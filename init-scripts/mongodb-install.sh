#!/usr/bin/env bash

curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
sudo apt update
sudo apt install mongodb-org -y
sudo systemctl start mongod.service
mongo --eval 'db.runCommand({connectionstatus: 1})'
sudo systemctl enable mongod
sudo sed -i 's/bindIp: 127.0.0.1/bindIp: 0.0.0.0/' /etc/mongod.conf
sudo systemctl restart mongod.service

# source = ../init-scripts/mongodb-install.sh
# destination = /home/ubuntu/mongodb-install.sh
# bash /home/ubuntu/mongodb-install.sh
