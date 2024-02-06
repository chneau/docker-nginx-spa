FROM nginx:alpine
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /
ENTRYPOINT ["/start.sh"]
