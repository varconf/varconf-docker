use mysql;
alter user 'root'@'localhost' identified with mysql_native_password by 'admin';
flush privileges;
update user set host='%' where user='root';
flush privileges;
select host, user from user;