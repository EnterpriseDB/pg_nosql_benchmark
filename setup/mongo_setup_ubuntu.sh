#!/bin/bash

set -e
set -x

# Install MongoDB 3.6 for Ubuntu
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
apt-get update
apt-get -y install mongodb-org bc

# Create service script
echo "[Unit]"                                                               > /lib/systemd/system/mongod.service
echo "Description=High-performance, schema-free document-oriented database" >> /lib/systemd/system/mongod.service
echo "After=network.target"                                                 >> /lib/systemd/system/mongod.service
echo "Documentation=https://docs.mongodb.org/manual"                        >> /lib/systemd/system/mongod.service
echo "[Service]"                                                            >> /lib/systemd/system/mongod.service
echo "User=mongodb"                                                         >> /lib/systemd/system/mongod.service
echo "Group=mongodb"                                                        >> /lib/systemd/system/mongod.service
echo "ExecStart=/usr/bin/mongod --bind_ip_all --config /etc/mongod.conf"    >> /lib/systemd/system/mongod.service
echo "PIDFile=/var/run/mongodb/mongod.pid"                                  >> /lib/systemd/system/mongod.service
echo "# file size"                                                          >> /lib/systemd/system/mongod.service
echo "LimitFSIZE=infinity"                                                  >> /lib/systemd/system/mongod.service
echo "# cpu time"                                                           >> /lib/systemd/system/mongod.service
echo "LimitCPU=infinity"                                                    >> /lib/systemd/system/mongod.service
echo "# virtual memory size"                                                >> /lib/systemd/system/mongod.service
echo "LimitAS=infinity"                                                     >> /lib/systemd/system/mongod.service
echo "# open files"                                                         >> /lib/systemd/system/mongod.service
echo "LimitNOFILE=64000"                                                    >> /lib/systemd/system/mongod.service
echo "# processes/threads"                                                  >> /lib/systemd/system/mongod.service
echo "LimitNPROC=64000"                                                     >> /lib/systemd/system/mongod.service
echo "# locked memory"                                                      >> /lib/systemd/system/mongod.service
echo "LimitMEMLOCK=infinity"                                                >> /lib/systemd/system/mongod.service
echo "# total threads (user+kernel)"                                        >> /lib/systemd/system/mongod.service
echo "TasksMax=infinity"                                                    >> /lib/systemd/system/mongod.service
echo "TasksAccounting=false"                                                >> /lib/systemd/system/mongod.service
echo "[Install]"                                                            >> /lib/systemd/system/mongod.service
echo "WantedBy=multi-user.target"                                           >> /lib/systemd/system/mongod.service

# Start MongoDB
systemctl daemon-reload
systemctl start mongod

# Set admin password
sleep 5
mongo 127.0.0.1:27017/admin --eval 'db.createUser({user:"admin", pwd:"password", roles:[{role:"root", db:"admin"}]})'
mongo 127.0.0.1:27017/benchmark --eval 'db.createUser({ user: "mongo", pwd: "mongo", roles:[{ role: "readWrite", db: "benchmark" }] })'

# Turn on authentication
systemctl stop mongod
cat << EOF >> /etc/mongod.conf
security:
  authorization: enabled
EOF

sed -i "s/--bind_ip_all/--auth --bind_ip_all/" /lib/systemd/system/mongod.service
systemctl start mongod

# Test
sleep 5
mongo --host 127.0.0.1 --port 27017 --username admin --authenticationDatabase admin --password password --eval "db.version()"
