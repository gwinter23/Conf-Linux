#!/bin/bash
export LC_ALL="en_US.UTF-8"
echo "##### Download Pakage Installer ESET PROTECT ####"
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
        wget wget https://download.eset.com/com/eset/apps/business/ech/latest/eset-bridge.x86_64.bin
    fi
    echo
    echo
    echo "###################checkfile mysql deb req#####################"
mysqldeb=mysql-apt-config_0.8.33-1_all.deb
if [ -f "$mysqldeb" ];
then
    echo "$mysqldeb has found."
else
    wget https://repo.mysql.com//mysql-apt-config_0.8.33-1_all.deb
fi
echo
echo
echo "###################checkfile mysql deb req#####################"
mysqldeb=mysql-connector-odbc-8.0.17-linux-debian10-x86-64bit.tar.gz
if [ -f "$mysqldeb" ];
then
    echo "$mysqldeb has found."
else
    wget https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc-8.0.17-linux-debian10-x86-64bit.tar.gz
fi
echo
echo 
echo 
echo "### Memberikan Previleges installer ###"
chmod +x server-linux-x86_64.sh
chmod +x agent-linux-x86_64.sh
chmod +x rdsensor-linux-x86_64.sh
chmod +x eset-bridge.x86_64.bin
echo 
echo 
echo
echo "##### Update upgrade pakage system operasi #####"
apt-get update -y
apt-get upgrade -y
echo 
echo 
echo
echo "##### install depedencies standart EP #####"
apt-get install openssl xvfb cifs-utils krb5-user ldap-utils ldap-utils libsasl2-modules-gssapi-mit snmp selinux-policy-dev samba lshw openjdk-17-jdk tomcat9 -y
echo 
echo
echo "##### MYSQL Database Install and configuration#####"
echo 
echo 
dpkg -i mysql-apt-config_0.8.33-1_all.deb
echo
echo 
apt-get update -y 
echo 
echo
#echo "mysql-server mysql-server/root_password password RunIF@!123!" | sudo debconf-set-selections
#echo "mysql-server mysql-server/root_password_again password RunIF@!123!" | sudo debconf-set-selections
#echo "mysql-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)" | sudo debconf-set-selections
#echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | sudo debconf-set-selections
#DEBIAN_FRONTEND=noninteractive apt-get install mysql-server -y
apt-get install mysql-server -y
echo
echo
echo
    echo "##############################"
    echo "insert cofiguration mysqld.cnf"
    echo "##############################"
echo 
echo "####################################" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "# ESET Requirement" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "max_allowed_packet = 500M" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "log_bin_trust_function_creators=1" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "innodb_log_file_size = 200M" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "innodb_log_files_in_group = 4" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "innodb_lock_wait_timeout=600" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
echo "####################################" | tee -a /etc/mysql/mysql.conf.d/mysqld.cnf
#mysql odbc check
echo "###############restart service mysql and check######################"
systemctl restart mysql
echo 
echo
systemctl status mysql
echo 
echo 
echo "#### ODBC Install######"
echo
apt-get install unixodbc
echo
echo 
echo "##check configure##"
echo 
echo "###(odbc resource conf list)####"
odbcinst -j
echo
echo "##(list check odbc configuration DSN)##"
myodbc-installer -d -l
echo 
echo
tar xvf mysql-connector-odbc-8.0.17-linux-debian10-x86-64bit.tar.gz
echo 
echo
#cd mysql-connector-odbc-8.0.17-linux-debian10-x86-64bit
echo 
echo
cp mysql-connector-odbc-8.0.17-linux-debian10-x86-64bit/bin/* /usr/local/bin/
cp mysql-connector-odbc-8.0.17-linux-debian10-x86-64bit/lib/* /usr/local/lib/
echo 
echo
myodbc-installer -a -d -n "MySQL ODBC 8.0 Driver" -t "Driver=/usr/local/lib/libmyodbc8w.so"
myodbc-installer -a -d -n "MySQL ODBC 8.0" -t "Driver=/usr/local/lib/libmyodbc8a.so"
echo
echo
echo "##### instaling ESET PROTECT#####"
./server-linux-x86_64.sh --skip-license --db-driver="MySQL ODBC 8.0 Driver" --db-hostname=127.0.0.1 --db-port=3306 --db-admin-username=root --db-admin-password='RunIF@!123!' --server-root-password='RunIF@!123!' --db-user-username=root --db-user-password='RunIF@!123!' --cert-hostname="*" --enable-imp-program
echo
echo 
./eset-bridge.x86_64.bin -y
echo 
echo 
./rdsensor-linux-x86_64.sh --skip-license
echo
echo 
systemctl status tomcat9
echo
echo
cp era.war /var/lib/tomcat9/webapps/
echo 
echo
systemctl restart tomcat9
echo
echo
echo "jeda 1 menit untuk instalasi agent"
sleep 1m
echo "agent deploy"
./agent-linux-x86_64.sh --skip-license --hostname=localhost --port=2222 --webconsole-hostname=localhost --webconsole-port=2223 --webconsole-user=administrator --webconsole-password='RunIF@!123!' --cert-auto-confirm --enable-imp-program
echo
echo 
apt-get install libxkbcommon-x11-0 libgbm-dev -y 
echo 
echo






