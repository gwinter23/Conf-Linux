#!/bin/bash

set -e  # Exit if any command fails

echo "[1/10] Update sistem..."
apt update && apt upgrade -y

echo "[2/10] Install OpenJDK 17..."
apt install -y openjdk-17-jdk wget

echo "[3/10] Membuat user tomcat..."
useradd -m -U -d /opt/tomcat -s /bin/false tomcat

echo "[4/10] Download dan ekstrak Apache Tomcat 9..."
cd /tmp
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.105/bin/apache-tomcat-9.0.105.tar.gz
tar xzvf apache-tomcat-9.0.105.tar.gz -C /opt/tomcat --strip-components=1

echo "[5/10] Set hak akses direktori..."
chown -R tomcat:tomcat /opt/tomcat

echo "[6/10] Setup file systemd unit..."
cat <<EOF > /etc/systemd/system/tomcat9.service
[Unit]
Description=Tomcat Server
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
WorkingDirectory=/opt/tomcat/
ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "[7/10] Reload systemd daemon..."
systemctl daemon-reload

echo "[8/10] Enable Tomcat agar otomatis berjalan saat boot..."
systemctl enable tomcat9

echo "[9/10] Jalankan service Tomcat..."
systemctl start tomcat9

echo "[10/10] Status Tomcat:"
systemctl status tomcat9 --no-pager

echo "[11/11] Download Era War ESET PROTECT:"
wget https://download.eset.com/com/eset/apps/business/era/webconsole/latest/era.war

echo "[12/12] Copy Era War to Tomcat Webapps"
cp era.war /opt/tomcat/webapps/

echo "[13/13 Stop Start Tomcat 9 Service"
systemctl stop tomcat9
systemctl start tomcat9

echo "Done Tomcat Instalation Access on you browser http://ip-address:8080/era"
