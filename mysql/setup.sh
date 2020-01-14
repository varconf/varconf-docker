#!/bin/bash
set -e

#启动mysql
echo '1.启动mysql....'
service mysql start

sleep 3
echo `service mysql status`

#导入数据
echo '2.开始导入数据....'
mysql < /schema.sql
echo '3.导入数据完毕....'

sleep 3
echo `service mysql status`

#重新设置mysql密码
echo '4.开始修改密码....'
mysql < /privileges.sql
echo '5.修改密码完毕....'

echo `service mysql status`
echo `mysql容器启动完毕,且数据导入成功`

tail -f /dev/null