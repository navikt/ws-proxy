FROM openresty/openresty:alpine-fat

ARG UID=101
ARG GID=101

RUN set -x \
  # create nginx user/group first, to be consistent throughout docker variants
    && addgroup -g $GID -S nginx || true \
    && adduser -S -D -H -u $UID -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx || true \

RUN set -x \
# nginx user must own the cache and etc directory to write cache and tweak the nginx config
    && chown -R $UID:0 /var/run/openresty \
    && chmod -R g+w /var/run/openresty \
    && chown -R $UID:0 /usr/local/openresty/nginx \
    && chmod -R g+w /usr/local/openresty/nginx

RUN /usr/local/openresty/luajit/bin/luarocks install lua-resty-openidc

# for å tillate lua-script å få tak i spesifikke miljøvariabler
RUN echo "env AZURE_APP_CLIENT_ID;" >> /usr/local/openresty/nginx/conf/nginx.conf
RUN echo "env WELL_KNOWN_URI;" >> /usr/local/openresty/nginx/conf/nginx.conf

COPY proxy.conf /etc/nginx/conf.d/default.conf
COPY jwt.lua /usr/local/openresty/nginx/

USER $UID