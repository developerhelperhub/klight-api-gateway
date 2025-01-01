FROM openresty/openresty:1.21.4.1-0-alpine

RUN apk add --no-cache \
    build-base \
    curl \
    cmake \
    gcc \
    g++ \
    make \
    git \
    wget \
    readline-dev \
    lua5.1 lua5.1-dev \
    yaml-dev \
    openssl openssl-dev

WORKDIR /app

RUN wget https://luarocks.org/releases/luarocks-3.9.2.tar.gz && \
    tar zxpf luarocks-3.9.2.tar.gz  && \
    cd luarocks-3.9.2 && \
    ./configure --lua-version=5.1 --with-lua-include=/usr/include && \
    make build && \
    make install && \
    luarocks --version && \
    cd /app && \
    rm -rf luarocks-3.9.2 luarocks-3.9.2.tar.gz

RUN git clone --depth 1 https://github.com/mongodb/mongo-c-driver.git && \
    cd mongo-c-driver && \
    mkdir cmake-build && cd cmake-build && \
    cmake -DENABLE_AUTOMATIC_INIT_AND_CLEANUP=OFF -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc) && make install && \
    cd ../.. && rm -rf mongo-c-driver


RUN luarocks install lyaml \
    && luarocks install openssl \
    && luarocks install lua-mongo \
    && luarocks install bcrypt \
    && luarocks install lua-resty-http \
    && luarocks install lua-resty-openidc \
    && luarocks install lua-resty-session \
    && luarocks install lua-resty-cookie \
    && luarocks install lua-resty-string \
    && luarocks install lua-resty-jwt \
    && luarocks install lua-cjson \
    && luarocks install lua-resty-redis

ENTRYPOINT /bin/sh