FROM nginxinc/nginx-unprivileged:latest

COPY proxy.conf /etc/nginx/conf.d/default.conf

