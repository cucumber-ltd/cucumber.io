FROM nginx

COPY nginx/ /etc/nginx/

CMD sed -i -e 's/$PORT/'"$PORT"'/' -e 's/$NAME/'"$NAME"'/' /etc/nginx/server.conf && nginx -g 'daemon off;'