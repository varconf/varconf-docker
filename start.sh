#!/bin/bash

#启动mysql
service mysql start
echo '1.启动mysql....'

sleep 3
echo `service mysql status`

#导入数据
echo '2.开始导入数据....'
mysql < /mysql/schema.sql

sleep 3
echo `service mysql status`

#重新设置mysql密码
echo '4.开始修改密码....'
mysql < /mysql/privileges.sql

sleep 3
echo `service mysql status`

echo '6.启动服务器....'
./varconf-server -s start
