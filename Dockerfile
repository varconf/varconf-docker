# 构建阶段
FROM golang:1.13 AS build

# 设置工作目录
WORKDIR /varconf-server/

# 下载后端代码并解压
RUN wget --no-check-certificate https://github.com/varconf/varconf-server/archive/v0.0.1.tar.gz
RUN tar -zxvf v0.0.1.tar.gz
RUN cp -r ./varconf-server-0.0.1/* ./
RUN rm -rf ./varconf-server-0.0.1
RUN rm -rf v0.0.1.tar.gz*

# 下载前端代码并解压
RUN wget --no-check-certificate https://github.com/varconf/varconf-ui/archive/v0.0.1.tar.gz
RUN tar -zxvf v0.0.1.tar.gz
RUN mv varconf-ui-0.0.1 varconf-ui
RUN rm -rf ./varconf-ui-0.0.1
RUN rm -rf v0.0.1.tar.gz*

# 编译静态应用
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -mod=vendor .

# 生产阶段
FROM mysql:5.7 AS prod

# 设置免密登录
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes

# 设置工作目录
WORKDIR /varconf/

# 从buil阶段拷贝二进制文件
COPY --from=build /varconf-server/varconf-server .
COPY --from=build /varconf-server/config.json .
COPY --from=build /varconf-server/varconf.sql .
COPY --from=build /varconf-server/varconf-ui/ ./varconf-ui/

# 将所需文件放到容器中
COPY /start.sh /varconf/start.sh
COPY /mysql/privileges.sql /mysql/privileges.sql
RUN mv ./varconf.sql /mysql/schema.sql

# 对外开放端口
EXPOSE 8088 3306

# 设置容器启动时执行的命令
CMD ["/bin/bash", "start.sh"]
