FROM nginx

COPY nginx/*.conf /etc/nginx/

# ARG PORT=8080
# ENV port=$PORT
# ARG NAME=cucumber.io
# ENV name=$NAME

# CMD sed -i -e "s|\$PORT|${port}|" -e "s|\$NAME|${name}|" /etc/nginx/server.conf && nginx -g 'daemon off;'

CMD sed -i -e 's/$PORT/'"$PORT"'/g' /etc/nginx/server.conf && nginx -g 'daemon off;'