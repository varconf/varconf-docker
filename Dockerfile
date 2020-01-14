# 构建阶段
FROM golang:1.13 AS build

# 设置工作目录
WORKDIR /varconf/

# 下载后端代码并解压
RUN mkdir /varconf-server
RUN cd /varconf-server
RUN wget --no-check-certificate https://github.com/varconf/varconf-server/archive/v0.0.1.tar.gz
RUN tar -zxvf v0.0.1.tar.gz
RUN cp -r ./varconf-server-0.0.1/* ./
RUN rm -rf ./varconf-server-0.0.1
RUN rm -rf v0.0.1.tar.gz*
RUN cd ../

# 下载前端代码并解压
RUN mkdir /varconf-ui
RUN cd /varconf-ui
RUN wget --no-check-certificate https://github.com/varconf/varconf-ui/archive/v0.0.1.tar.gz
RUN tar -zxvf v0.0.1.tar.gz
RUN cp -r ./varconf-ui-0.0.1/* ./
RUN rm -rf ./varconf-ui-0.0.1
RUN rm -rf v0.0.1.tar.gz*
RUN cd ../

# 编译静态应用
RUN cd /varconf-server
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -mod=vendor .

# 生产阶段
FROM mysql:5.7 AS prod

# 设置免密登录
ENV MYSQL_ALLOW_EMPTY_PASSWORD yes

# 设置工作目录
WORKDIR /varconf/

# 从buil阶段拷贝二进制文件
COPY --from=build /varconf/varconf-server/varconf-server .
COPY --from=build /varconf/varconf-server/varconf.sql .
COPY --from=build /varconf/varconf-ui/ .
RUN ls

# 将所需文件放到容器中
COPY /mysql/setup.sh /mysql/setup.sh
COPY varconf.sql /mysql/schema.sql
COPY /mysql/privileges.sql /mysql/privileges.sql

# 对外开放端口
EXPOSE 80,3306

# 设置容器启动时执行的命令
CMD ["sh", "/mysql/setup.sh && ./varconf-server"]
