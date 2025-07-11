#!/bin/bash

echo "##### Update Pakage And Repository Rocky 9.4 ####"
yum update -y
yum upgrade -y

echo "##### install depedencies standart EP #####"
yum install nano java-17-openjdk tomcat openssl xorg-x11-server-Xvfb cifs-utils krb5-workstation openldap-clients cyrus-sasl-gssapi cyrus-sasl-ldap net-snmp-utils net-snmp policycoreutils-devel lshw wget tar -y 

echo "#### Install mysql database ####"
yum install mysql-server.x86_64 -y

echo "#### Configuring mysqld ####"
systemctl start mysqld
systemctl enable mysqld

#echo # Mengambil password sementara MySQL
#TEMP_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Mengotomatiskan mysql_secure_installation
#sudo mysql -u root -p"$TEMP_PASSWORD" --connect-expired-password <<EOF
sudo mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'ts12345';
UNINSTALL PLUGIN validate_password;
SET GLOBAL validate_password.length = 6;
SET GLOBAL validate_password.policy = LOW;
DELETE FROM mysql.user WHERE User='';
DROP DATABASE test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

echo "MySQL secure installation telah selesai secara otomatis."

sudo tee -a /etc/my.cnf.d/mysql-server.cnf > /dev/null <<EOL

####################################
# ESET Requirement
max_allowed_packet = 500M
log_bin_trust_function_creators=1
innodb_log_file_size = 200M
innodb_log_files_in_group = 4
innodb_lock_wait_timeout=600
####################################

EOL

# Memulai ulang layanan MySQL agar perubahan diterapkan
sudo systemctl restart mysqld

echo "Konfigurasi telah ditambahkan dan layanan MySQL telah dimulai ulang."

echo "### Install ODBC Driver ####"
yum install unixODBC -y
yum install mariadb-connector-odbc -y


echo ### Download Installer EP dan Part lainnya ###
echo "###################checkfile era war req data#####################"
    erawar=era.war
    if [ -f "$erawar" ];
    then
        echo "$erawar has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/webconsole/latest/era.war
    fi

    echo "###################checkfile era req data####################"
    server=server-linux-x86_64.sh
    if [ -f "$server" ];
    then
        echo "$server has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/server/linux/latest/server-linux-x86_64.sh
    fi

    echo "###################checkfile agent req data #####################"
    agent=agent-linux-x86_64.sh
    if [ -f "$agent" ];
    then
        echo "$agent has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/agent/latest/agent-linux-x86_64.sh
    fi

    echo "###################checkfile rd data#####################"
    rd=rdsensor-linux-x86_64.sh
    if [ -f "$rd" ];
    then
        echo "$rd has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/rdsensor/latest/rdsensor-linux-x86_64.sh
    fi
    echo
    echo
    
    echo "###################checkfile ESET Bridge req data#####################"
    eb=eset-bridge.x86_64.bin
    if [ -f "$eb" ];
    then
        echo "$eb has found."
    else
        wget https://download.eset.com/com/eset/apps/business/ech/latest/eset-bridge.x86_64.bin
    fi
    echo
    echo

echo "### Memberikan Previleges installer ###"
chmod +x server-linux-x86_64.sh
chmod +x agent-linux-x86_64.sh
chmod +x rdsensor-linux-x86_64.sh
chmod +x eset-bridge.x86_64.bin

echo "### Deploy ESET PROTECT dan Part pendukungnya ####"
echo
echo

sudo ./server-linux-x86_64.sh --skip-license --db-driver="MariaDB" --db-hostname=127.0.0.1 --db-port=3306 --db-admin-username=root --db-admin-password=ts12345 --server-root-password=ts@12345678 --db-user-username=root --db-user-password=ts12345 --cert-hostname="*" --enable-imp-program

echo "Deploy ESET BRIDGE"
sudo ./eset-bridge.x86_64.bin -y

#echo "Deploy RD Sensor"
#sudo ./rdsensor-linux-x86_64.sh --skip-license

echo "##### Insert Era War to Tomcat folder #####"
cp era.war /var/lib/tomcat/webapps/
systemctl enable tomcat
systemctl restart tomcat 
ls -lsb /var/lib/tomcat/webapps/

echo "#### disable firewald please checking again ####"
systemctl disable firewalld
systemctl stop firewalld
echo 
echo "jeda 3 menit untuk instalasi agent"
sleep 3m
echo "agent deploy"
echo 
echo 
sudo ./agent-linux-x86_64.sh --skip-license --hostname=localhost --port=2222 --webconsole-hostname=localhost --webconsole-port=2223 --webconsole-user=administrator --webconsole-password="ts@12345678" --cert-auto-confirm --enable-imp-program

echo "ESET PROTECT Installer Script is Finish check history script untuk mencari error atau issue Thanks, Build By RAM"



