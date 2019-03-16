FROM nginx

COPY nginx/*.conf /etc/nginx/

ENV port=$PORT
ARG NAME=cucumber.io
ENV name=$NAME

CMD sed -i -e 's/$PORT/'"$port"'/g' -e 's/$NAME/'"$name"'/g' /etc/nginx/server.conf && nginx -g 'daemon off;'