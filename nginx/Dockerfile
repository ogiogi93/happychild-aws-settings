FROM nginx:1.15.6

ENV USER='happychild2018'
ENV PASSWORD='2907hfd7Sy780s'

RUN apt-get update && \
  apt-get install -y apache2-utils python-pip && \
  pip install awscli

COPY run-nginx.sh /usr/local/bin/run-nginx.sh
RUN chmod 755 /usr/local/bin/run-nginx.sh

COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

RUN htpasswd -bc /etc/nginx/.htpasswd "$USER" "$PASSWORD"

CMD ["/usr/local/bin/run-nginx.sh"]
