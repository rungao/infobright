#!/bin/bash

## author: gaox
## date: 2016-11-10
## update:
## email: gaox@2345.com
## prupose: infobright install

info_db_user="infobright231"
info_db_pass="o)qKjVIs0#Pe"
info_conf_path="/opt/app/infobright/data/brighthouse.ini"
info_name="infobright-4.0.7"
info_rpm_pack="infobright-4.0.7-0-x86_64-ice.rpm"
info_rpm_url="http://45.78.32.29/${info_rpm_pack}"

rpm_query=`rpm -q $info_name`
if [ $rpm_query != '' ]; then
    echo "$info_name is install already."
    exit
fi

#wget -cP /opt/src/ $info_rpm_url

cd /opt/src/ && rpm -ivh $info_rpm_pack --prefix=/opt/data01/app/

echo "product regeister, please enter N"

cd /opt/data01/app/infobright/ && bash ./postconfig.sh

echo "infobright service start"

/etc/init.d/mysqld-ib start

# set user/pass

echo "set infobright user pass, pass default is empty, please enter"

mysql-ib -uroot -p -e "create database flyingfish default charset utf8"
mysql-ib -uroot -p -e "INSERT INTO mysql.user (Host, User, Password) VALUES ('%', '${info_db_user}', PASSWORD('${info_db_pass}'));"
mysql-ib -uroot -p -e "GRANT ALL PRIVILEGES ON `flyingfish`.* TO '${info_db_user}'@'180.168.34.146' IDENTIFIED BY '${info_db_pass}';"
mysql-ib -uroot -p -e "GRANT ALL PRIVILEGES ON `flyingfish`.* TO '${info_db_user}'@'180.167.67.10' IDENTIFIED BY '${info_db_pass}';"
mysql-ib -uroot -p -e "GRANT ALL PRIVILEGES ON `flyingfish`.* TO '${info_db_user}'@'localhost' IDENTIFIED BY '${info_db_pass}';"
mysql-ib -uroot -p -e "GRANT ALL PRIVILEGES ON `flyingfish`.* TO '${info_db_user}'@'172.16.20.232' IDENTIFIED BY '${info_db_pass}';"
mysql-ib -uroot -p -e "FLUSH PRIVILEGES;"

# set infobright conf

echo "infobright user create success"

echo "user: $info_db_user"

echo "pass: $info_db_pass"

