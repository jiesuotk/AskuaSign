FROM alpine:latest 
ARG DOMAIN 
ENV DOMAIN=$DOMAIN 
 
# 安装依赖（包括 zsign 的编译工具）
RUN apk update && apk add --no-cache \
    git nodejs npm cmake make g++ openssl-dev zlib-dev zip 
 
# 复制本地 zsign 代码到容器并编译 
COPY ./zsign /tmp/zsign 
RUN mkdir -p /tmp/zsign/build && cd /tmp/zsign/build && \
    cmake .. && make && cp zsign /usr/local/bin/zsign 
 
# 直接使用当前目录的 AskuaSign 代码（无需 git clone）
COPY . /root/AskuaSign 
 
# 设置 AskuaSign 环境变量 
RUN cd /root/AskuaSign && \
    npm install && \
    sed -i "3s|.*|JWTToken=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 39)|" .env && \
    sed -i "4s|.*|Domain=$DOMAIN|" .env && \
    sed -i "1s|localhost|mongo|" .env 
 
EXPOSE 3000 
WORKDIR /root/AskuaSign 
CMD ["node", "."]
