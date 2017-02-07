#!/bin/bash

## author: gaox
## date : 2016-11-10
## update :
## email: gaox@2345.com
## purpose: backup infobright data to backup server

time=`date "+%Y-%m-%d %H:%M:%S"`

infobright_path="/opt1/infobright_data"
infobright_dbname="flyingfish"

rsync="/opt/app/rsync/bin/rsync"
#rsync_pass="z@xzpw#lmxd#jhmj@h"
rsync_pass_file="/opt/app/rsync/etc/rsync.httpd.pas"
#rsync_option="-avn --delete --exclude=brighthouse.ini --exclude=*.pid --timeout=4096 --bwlimit=40960 --progress --port=3334 --password-file=$rsync_pass_file root@172.16.20.231::infobright"
rsync_option="-avzP --delete --exclude=brighthouse.ini --exclude=*.pid --timeout=180 --bwlimit=40960 --progress --port=3334 --password-file=$rsync_pass_file root@172.16.20.231::infobright"
rsync_log="/opt/case/calc.t.x.2345.com/do/infobright_recored.txt"
rsync_error_log="/opt/case/calc.t.x.2345.com/do/infobright_rsyncError.log"

infobright_host="172.16.20.231"
infobright_port="5029"
infobright_user="infobright231"
infobright_pass='o)qKjVIs0#Pe'

infobright_local_user="infobright231"
infobright_local_pass='o)qKjVIs0#Pe'
infobright_local_port="5029"

mkdir -p /opt/case/calc.t.x.2345.com/do/

function infobright_stop() {
    /etc/init.d/mysqld-ib stop | tee -a $rsync_log
}

function infobright_start() {
    /etc/init.d/mysqld-ib start | tee -a $rsync_log
}

function infobright_lock() {
    mysql-ib -h${infobright_host} -u${infobright_user} --port=${infobright_port} -p${infobright_pass} -e "flush tables with read lock;" > /dev/null
    if [ $? != '0' ]
    then
        echo "${time} infobright lock tables error" | tee -a $rsync_log
        exit 1
    fi
    echo "${time} infobright lock tables success" | tee -a $rsync_log
}

function infobright_unlock() {
    mysql-ib -h${infobright_host} -u${infobright_user} --port=${infobright_port} -p${infobright_pass} -e "unlock tables;" > /dev/null
    if [ $? != '0' ]
    then
        echo "${time} infobright unlock tables error" | tee -a $rsync_log
        exit 1
    fi
    echo "${time} infobright unlock tables success" | tee -a $rsync_log    
}

function do_rsync() {
    #dirname $rsync_pass_file | xargs mkdir -p
    #echo $rsync_pass > $rsync_pass_file
    #chmod 600 $rsync_pass_file
    $rsync $rsync_option $infobright_path
    wait
    if [ $? != '0' ]
    then 
        echo "rsync error" | tee -a $rsync_log
        exit 1
    fi
    echo $time | tee -a $rsync_log
}

function chown_data() {
    chown mysql.mysql $infobright_path -R
    
}

function check_data() {
    new_table_name=`cd ${infobright_path}/${infobright_dbname}/ && ls -t *.frm | head -1 | awk -F. '{print $1}'`
    check_sql="select count(*) FROM ${new_table_name};"
    mysql_num_local=`mysql-ib -u${infobright_local_user} -p${infobright_local_pass} --database=${infobright_dbname} --port=${infobright_local_port} -e "${check_sql}" | tail -n +2`
    mysql_num_server=`mysql-ib -h${infobright_host} -u${infobright_user} -p${infobright_pass} --database=${infobright_dbname} --port=${infobright_port} -e "${check_sql}" | tail -n +2`
    if [[ $mysql_num_local != $mysql_num_server ]]
    then
        echo "table:$infobright_dbname-$new_table_name check error, mysql-local-count:$mysql_num_local, mysql-server-count: $mysql_num_server" | tee -a $rsync_log
        return
    fi
    echo "infobright $new_table_name check sucess, server count $mysql_num_server, local count $mysql_num_local, veity sucess."  | tee -a $rsync_log
}

function main() {
    infobright_lock
    infobright_stop
    do_rsync
    chown_data
    infobright_unlock
    infobright_start
    check_data
}

main
echo "${time} infobright backup complete" | tee -a $rsync_log
/etc/init.d/mysqld-ib start | tee -a $rsync_log
