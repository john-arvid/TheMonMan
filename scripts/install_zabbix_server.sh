#!/bin/bash

# For debian 8, Zabbix 3.2 mysql

# Oppdater før installasjon
apt-get update && apt-get -y upgrade

# Skaff nytt repo for å få ønsket version
wget http://repo.zabbix.com/zabbix/3.2/debian/pool/main/z/zabbix-release/zabbix-release_3.2-1+jessie_all.deb
dpkg -i zabbix-release_3.2-1+jessie_all.deb
apt-get update

#TODO: Få inn passord automatisk. TheMonMan
# Installer zabbix med mysql, 
apt-get install -y zabbix-server-mysql zabbix-frontend-php

# Sett innodb (etter dokumentasjon zabbix), lag database og bruker
mysql -uroot -pTheMonMan
SET GLOBAL innodb_file_per_table=1;
create database zabbix character set utf8 collate utf8_bin;
grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
quit;

# Flytt data inn i database
zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql zabbix -uzabbix -pzabbix

# Endre zabbix_server.conf med nødvendig informasjon
sed -i '/DBHost=/c\DBHost=localhost' /etc/zabbix/zabbix_server.conf
sed -i '/DBName=/c\DBName=zabbix' /etc/zabbix/zabbix_server.conf
sed -i '/DBUser=/c\DBUser=zabbix' /etc/zabbix/zabbix_server.conf
sed -i '/DBPassword=/c\DBPassword=zabbix' /etc/zabbix/zabbix_server.conf

# Start zabbix og legg til autostart
service zabbix-server start
update-rc.d zabbix-server enable

# Endre php instillinger
sed -i '/php_value max_execution_time/c\php_value max_execution_time 300' /etc/zabbix/apache.conf
sed -i '/php_value memory_limit/c\php_value memory_limit 128M' /etc/zabbix/apache.conf
sed -i '/php_value post_max_size/c\php_value post_max_size 16M' /etc/zabbix/apache.conf
sed -i '/php_value upload_max_filesize/c\php_value upload_max_filesize 2M' /etc/zabbix/apache.conf
sed -i '/php_value max_input_time/c\php_value max_input_time 300' /etc/zabbix/apache.conf
sed -i '/php_value always_populate_raw_post_data/c\php_value always_populate_raw_post_data -1' /etc/zabbix/apache.conf
sed -i '/php_value date.timezone/c\php_value date.timezone Europe/Oslo' /etc/zabbix/apache.conf

# Restart webserver
service apache2 restart

# Gi ut info om ip adresse
echo '

Go to this address
'
ip addr
echo '
/zabbix

'


