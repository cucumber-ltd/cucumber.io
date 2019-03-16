FROM nginx

COPY nginx/*.conf /etc/nginx/

CMD sed -i -e 's/$PORT/'"$PORT"'/g' -e 's/$NAME/'"$NAME"'/g' /etc/nginx/server.conf && nginx -g 'daemon off;'