FROM nginx

COPY nginx/*.conf /etc/nginx/

CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/server.conf && nginx -g 'daemon off;'
