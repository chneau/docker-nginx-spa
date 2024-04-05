FROM nginx:alpine
COPY --chown=1000:1000 nginx.conf /etc/nginx/nginx.conf
COPY --chown=1000:1000 start.sh /
RUN chown -R 1000:1000 /var/cache/nginx && \
    chown -R 1000:1000 /var/log/nginx && \
    chown -R 1000:1000 /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R 1000:1000 /var/run/nginx.pid
USER 1000:1000
ENV PREFIX=_
ENTRYPOINT exec /start.sh
