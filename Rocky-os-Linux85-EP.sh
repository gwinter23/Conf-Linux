------------- ESET PROTECT Deploy On Rocky Linux 8.5--------------

# update list
yum update 
yum upgrade

#install pakage wget 
yum install pakage 

#download pakage update pakage
wget https://dev.mysql.com/get/mysql80-community-release-el8-3.noarch.rpm

yum update

yum repolist all | grep mysql

#installing mysql pakage
yum install mysql-server mysql-connector-odbc
 
systemctl status mysqld
systemctl start mysqld.service
systemctl enable mysqld.service

# securing mysql setup 
mysql_secure_installation

# check login
mysql -u root

# Tomcat 9 deploy
yum install java-11-openjdk java-11-openjdk-devel

groupadd tomcat

mkdir /opt/tomcat

useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat


wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.60/bin/apache-tomcat-9.0.60.tar.gz

ls -lsb /opt/tomcat/

tar -xvf apache-tomcat-9.0.60.tar.gz -C /opt/tomcat --strip-components=1

chown -R tomcat: /opt/tomcat

sh -c 'chmod +x /opt/tomcat/bin/*.sh'

alternatives --list | grep ^java

# insert deamon and service start trigger 
nano /etc/systemd/system/tomcat.service
##### insert systemd trigger service script #######
[Unit]
Description=Apache Tomcat Web Application Container
Wants=network.target
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME= /usr/lib/jvm/java-11-openjdk-11.0.14.1.1-2.el8_5.x86_64

Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1G -Djava.net.preferIPv4Stack=true'
Environment='JAVA_OPTS=-Djava.awt.headless=true'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
SuccessExitStatus=143

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target

#######################
# restart service
systemctl daemon-reload
systemctl start tomcat
systemctl enable tomcat
systemctl restart tomcat
systemctl status tomcat

# open port on firewal-cmd
firewall-cmd --add-port=8080/tcp --permanent
firewall-cmd --reload

# download pakage eset protect 
wget https://download.eset.com/com/eset/apps/business/era/webconsole/latest/era.war
wget https://download.eset.com/com/eset/apps/business/era/server/linux/latest/server-linux-x86_64.sh
wget https://download.eset.com/com/eset/apps/business/era/agent/latest/agent-linux-x86_64.sh

# copy era.war data to directory tomcat 
cp era.war /opt/tomcat/webapps/
systemctl restart tomcat
ls -lsb /opt/tomcat/webapps/

# test via browser
http://ip or domain:8080/era

## installing odbc, mysql requirement and preparing install ep service 
yum install xorg-x11-server-Xvfb policycoreutils-devel

wget https://cdn.mysql.com//Downloads/Connector-ODBC/8.0/mysql-connector-odbc-8.0.28-linux-glibc2.12-x86-64bit.tar.gz
tar -xf mysql-connector-odbc-8.0.28-linux-glibc2.12-x86-64bit.tar.gz
ls

cp /root/mysql-connector-odbc-8.0.28-linux-glibc2.12-x86-64bit/lib/libmyodbc8* /usr/lib64/

# check odbcinst.ini
nano /etc/odbcinst.ini

check this script if you not look script insert manualy
#######################################
[MySQL ODBC 8.0 Unicode Driver]
Driver=/usr/lib64/libmyodbc8w.so
UsageCount=1

[MySQL ODBC 8.0 ANSI Driver]
Driver=/usr/lib64/libmyodbc8a.so
UsageCount=1
######################################

#insert conf script on you mysql conf
nano /etc/my.cnf.d/mysql-server.cnf

### insert this conf ####

####################################
# ESET Requirement
max_allowed_packet = 500M
log_bin_trust_function_creators=1
innodb_log_file_size = 200M
innodb_log_files_in_group = 4
innodb_lock_wait_timeout=600
####################################

# restart service mysql
systemctl restart mysqld

# give permission on installer pakage 
chmod +x server-linux-x86_64.sh
chmod +x agent-linux-x86_64.sh


# instaling service ep
./server-linux-x86_64.sh --skip-license --db-driver="MySQL ODBC 8.0 Unicode Driver" --db-hostname=127.0.0.1 --db-port=3306 --db-admin-username=root --db-admin-password=qwerty123 --server-root-password="qwerty123" --db-user-username=root --db-user-password=qwerty123 --cert-hostname="*" --enable-imp-program

# instaling agent 
./agent-linux-x86_64.sh --skip-license --hostname=localhost --port=2222 --webconsole-hostname=localhost --webconsole-port=2223 --webconsole-user=administrator --webconsole-password="qwerty123" --cert-auto-confirm --enable-imp-program


#### information logging status, thats status can help you to solve error

systemctl status eraserver

tail -f /var/log/eset/RemoteAdministrator/Server/trace.log

systemctl status tomcat

systemctl status eraagent





