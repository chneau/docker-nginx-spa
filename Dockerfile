FROM nginx:alpine
COPY --chown=1000:1000 nginx.conf /etc/nginx/nginx.conf
COPY --chown=1000:1000 start.sh /
RUN chmod +x /start.sh && \
    chown -R 1000:1000 /var/cache/nginx && \
    chown -R 1000:1000 /var/log/nginx && \
    chown -R 1000:1000 /etc/nginx/conf.d && \
    chown -R 1000:1000 /usr/share/nginx && \
    touch /tmp/nginx.pid && \
    chown -R 1000:1000 /tmp/nginx.pid

EXPOSE 8080

USER 1000:1000
ENV PREFIX=_

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://127.0.0.1:8080/ || exit 1

ENTRYPOINT ["/start.sh"]

