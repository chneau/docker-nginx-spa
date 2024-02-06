FROM nginx:alpine as final
COPY nginx.conf /etc/nginx/nginx.conf
COPY start.sh /
ENTRYPOINT ["/start.sh"]
