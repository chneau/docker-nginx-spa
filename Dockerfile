FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /
ENV PREFIX=_
ENTRYPOINT ["/start.sh"]
