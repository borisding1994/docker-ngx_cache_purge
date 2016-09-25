FROM alpine:latest
MAINTAINER borsiding@zhulux.com

ENV NGINX_VERSION nginx-1.11.4
ENV CACHE_PURGE_VERSION 2.3
ADD https://github.com/yaoweibin/ngx_http_substitutions_filter_module/archive/v0.6.4.tar.gz ngx_http_substitutions_filter_module-0.6.4.tar.gz

RUN apk --update add openssl-dev pcre-dev zlib-dev wget build-base && \
    mkdir -p /tmp/src && \
    cd /tmp/src && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    wget https://github.com/FRiCKLE/ngx_cache_purge/archive/${CACHE_PURGE_VERSION}.tar.gz --no-check-certificate && \
    tar -zxvf ${CACHE_PURGE_VERSION}.tar.gz && \
    tar -zxvf ngx_http_substitutions_filter_module-0.6.4.tar.gz && \
    cd /tmp/src/${NGINX_VERSION} && \
    ./configure \
        --with-http_ssl_module \
        --with-http_gzip_static_module \
        --prefix=/etc/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --http-log-path=/app/logs/access.log \
        --error-log-path=/app/logs/error.log \
        --sbin-path=/usr/local/sbin/nginx \
        --add-module=/tmp/src/ngx_http_substitutions_filter_module-0.6.4 \
        --add-module=/tmp/src/ngx_cache_purge-${CACHE_PURGE_VERSION} \
        --with-http_sub_module && \
    make && \
    make install && \
    apk del build-base && \
    rm -rf /tmp/src && \
    rm -rf /var/cache/apk/*


WORKDIR /app
VOLUME /app

ADD . .
ADD conf/nginx.conf /etc/nginx/
ADD startup.sh /startup.sh

RUN mkdir -p /app/logs

EXPOSE 80 443
CMD ["/startup.sh"]
