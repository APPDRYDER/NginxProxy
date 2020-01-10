#!/bin/bash
#
#
. envvars.sh

echo "Stopping Nginx"
service nginx status
service nginx stop
sleep 2

echo "Creating $NGINX_REVERSE_PROXY_CONFIG_FILE"
cat << EOF > $NGINX_REVERSE_PROXY_CONFIG_FILE
server {
  listen $NGINX_HTTP_PORT;
  listen [::]:$NGINX_HTTP_PORT;

  access_log /var/log/nginx/reverse-access.log;
  error_log /var/log/nginx/reverse-error.log;

  location / {
                proxy_pass http://$APPD_CONTROLLER_HOST; }
}

server {
  listen $NGINX_HTTPS_PORT;
  listen [::]:$NGINX_HTTPS_PORT;

  access_log /var/log/nginx/reverse-access.log;
  error_log /var/log/nginx/reverse-error.log;

  location / {
                proxy_pass https://$APPD_CONTROLLER_HOST:443;
             }
}
EOF
######

echo "Configuring $NGINX_REVERSE_PROXY_CONFIG_FILE" 
unlink /etc/nginx/sites-enabled/default
cp $NGINX_REVERSE_PROXY_CONFIG_FILE /etc/nginx/sites-available/
ln -s /etc/nginx/sites-available/$NGINX_REVERSE_PROXY_CONFIG_FILE /etc/nginx/sites-enabled/$NGINX_REVERSE_PROXY_CONFIG_FILE

echo "Testing configuration"
nginx -t

echo "Starting Nginx"
service nginx status
service nginx restart
service nginx status

echo "Complete"

# Hold container open
while (true); do
    sleep 60;
done
