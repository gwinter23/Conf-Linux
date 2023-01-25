#!/bin/bash
echo "AIO Script Build for Ubuntu 20.04 LTS Server"
echo "1) Backup Server"
echo "2) Upgrade"
echo "3) Update OS"
echo "4) ESET Bridge Deploy"
echo "5) ESET PROTECT Deploy "
echo "6) I do not know !"
read case;
#simple case bash structure
# note in this case $case is variable and does not have to
# be named case this is just an example
case $case in
    1) echo "Backup Server"
    echo "directory eralama"
    mkdir /home/eralama
    echo "stop service tomcat dan eraserver"
    systemctl stop tomcat9
    systemctl stop eraserver
    echo "backup era_war"
    mv /var/lib/tomcat9/webapps/* /home/eralama
    echo "db_backup"
    mysqldump --host localhost --disable-keys --extended-insert --routines -u root -p era_db > backup_$(date +%Y%m%d).sql
    echo "start again tomcat and server"
    systemctl start tomcat9
    systemctl start eraserver
    ;;
    2) echo "Upgrade ERA"
    mkdir /home/new_pkg_eset
    systemctl stop tomcat9
    systemctl stop eraserver
    echo "###################Pakage New Version ERA#####################"
    erawar=/home/new_pkg_eset/era.war
    if [ -f "$erawar" ];
    then
        echo "$erawar has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/webconsole/latest/era.war -P /home/new_pkg_eset
    fi
    echo "###################Pakage New Version Server#####################"
    server=/home/new_pkg_eset/server=server-linux-x86_64.sh
    if [ -f "$server" ];
    then
        echo "$server has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/server/linux/latest/server-linux-x86_64.sh -P /home/new_pkg_eset
    fi
    echo "###################checkfile rd data#####################"
    rd=/home/new_pkg_eset/rdsensor-linux-x86_64.sh
    if [ -f "$rd" ];
    then
        echo "$rd has found."
    else
        wget https://download.eset.com/com/eset/apps/business/era/rdsensor/latest/rdsensor-linux-x86_64.sh -P /home/new_pkg_eset
    fi
    cp /home/new_pkg_eset/era.war /var/lib/tomcat9/webapps/
    chmod +x /home/new_pkg_eset/server-linux-x86_64.sh
    ./home/new_pkg_eset/server-linux-x86_64.sh --skip-license
    systemctl restart tomcat9
    systemctl start eraserver
    ;;
    3) echo "Update Upgrade pakage"
    apt-get update -y 
    apt-get upgrade -y 
    ;;
    4) echo "ESET Bridge Install"
    wget https://download.eset.com/com/eset/apps/business/ech/latest/eset-bridge.x86_64.bin
    chmod +x eset-bridge.x86_64.bin
    ./eset-bridge.x86_64.bin
    ;;
    5) echo "ESET PROTECT Deploy"
    #ESET PROTECT INSTALL BY RAM SCRIPT
    echo "#########################################"
    echo "###############"
    echo "This is script build by ram you can use this script closely not distribute for general purpose"
    echo "###############"
    echo "#########################################"
    echo
    echo "###########Download Installer###################"
    echo 
    #Download Installer
    echo
    echo "###################checkfile mysql deb req#####################"
    mysqldeb=mysql-apt-config_0.8.22-1_all.deb
    if [ -f "$mysqldeb" ];
    then
        echo "$mysqldeb has found."
    else
        wget https://repo.mysql.com//mysql-apt-config_0.8.22-1_all.deb
    fi

    echo "###################checkfile odbc req#####################"
    odbc=mysql-connector-odbc-8.0.17-linux-ubuntu18.04-x86-64bit.tar.gz
    if [ -f "$odbc" ];
    then
        echo "$odbc has found."
    else
        wget https://cdn.mysql.com/archives/mysql-connector-odbc-8.0/mysql-connector-odbc-8.0.17-linux-ubuntu18.04-x86-64bit.tar.gz
    fi

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
    echo "#################Pemission change#####################"
    #Permission change
    chmod +x server-linux-x86_64.sh
    chmod +x agent-linux-x86_64.sh
    chmod +x rdsensor-linux-x86_64.sh
    ls -lsb
    echo
    echo "#############add repository#######################"
    #add repository
    add-apt-repository ppa:rock-core/qt4
    dpkg -i mysql-apt-config_0.8.22-1_all.deb
    echo
    echo "#########################update && upgrade pakage##########################" 
    #update && upgrade pakage 
    apt update && sudo apt upgrade -y
    echo
    echo "######################pakage install######################"
    #pakage install
    apt install -y wget lshw default-jdk tomcat9 unixodbc libodbc1 xvfb cifs-utils libqtwebkit4 krb5-user winbind ldap-utils snmp ldap-utils libsasl2-modules-gssapi-mit selinux-policy-dev samba apache2 apache2-utils libapache2-mod-wsgi
    echo 
    echo "#######################check pakage list###############################"
    #check pakage list 
    dpkg -l | grep mysql
    apt list | grep mysql
    echo
    echo "#############################instaling mysql########################"
    echo
    #install mysql 
    apt-get install mysql-community-server -y
    echo
        echo "##############################"
        echo "insert cofiguratiot mysqld.cnf"
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
    #systemctl status mysql
    echo "######extract_odbc########"
    tar xvzf mysql-connector-odbc-8.0.17-linux-ubuntu18.04-x86-64bit.tar.gz
    echo "############copy dobc data################"
    cp mysql-connector-odbc-8.0.17-linux-ubuntu18.04-x86-64bit/lib/libmyodbc8* /usr/lib/x86_64-linux-gnu/odbc
    echo "#####ls command check odbc data#####"
    odbcinst -j
    ls -lsb /usr/lib/x86_64-linux-gnu/odbc/
    echo
    #configuration odbc data mysql
    echo "######## configuration odbc /etc/odbcinst.ini#########################"
    echo
    touch /etc/odbcinst.ini
    echo "#####insert configuration#####" | tee -a /etc/odbcinst.ini
    echo "[MySQL ODBC 8.0 Unicode Driver]" | tee -a /etc/odbcinst.ini
    echo "Driver=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8w.so" | tee -a /etc/odbcinst.ini
    echo "#SETUP=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8S.so" | tee -a /etc/odbcinst.ini
    echo "UsageCount=1" | tee -a /etc/odbcinst.ini
    echo "[MySQL ODBC 8.0 ANSI Driver]" | tee -a /etc/odbcinst.ini
    echo "Driver=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8a.so" | tee -a /etc/odbcinst.ini
    echo "#SETUP=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8S.so" | tee -a /etc/odbcinst.ini
    echo "UsageCount=1" | tee -a /etc/odbcinst.ini
    #copy data web to tomcat
    echo "#####Web data copy to root directory tomcat#####"
    cp era.war /var/lib/tomcat9/webapps/
    systemctl restart tomcat9
    #systemctl status tomcat9
    echo
    #running eset protect service install
    echo "##### Running install ESET PROTECT####"
    echo 
    ./server-linux-x86_64.sh --skip-license --db-driver="MySQL ODBC 8.0 Unicode Driver" --db-hostname=127.0.0.1 --db-port=3306 --db-admin-username=root --db-admin-password=webadmin123 --server-root-password=webadmin123 --db-user-username=root --db-user-password=webadmin123 --cert-hostname="*" --enable-imp-program
    #systemctl status eraserver
    echo
    echo "#############finish enjoy you use server###################"
    echo 
    ;;
    6) exit
esac
