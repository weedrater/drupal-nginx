#!/bin/bash

set -e

if [[ ! -z $DEBUG ]]; then
  set -x
fi

# Set upstream name
if [ -n "$NGINX_UPSTREAM_NAME" ]; then
    sed -i 's/UPSTREAM_NAME/'"${NGINX_UPSTREAM_NAME}"'/' /etc/nginx/nginx.conf
fi

# Ensure drupal version defined.
if [ -z "$DRUPAL_VERSION" ]; then
    DRUPAL_VERSION=8
fi

# Copy default nginx config.
if [[ ! "$(ls -A /etc/nginx/conf.d)" ]]; then
	echo " --  copying drupal nginx configs"
    cp /opt/drupal${DRUPAL_VERSION}.conf /etc/nginx/conf.d/
fi

# Configure docroot.
if [[ -n "$NGINX_DOCROOT" ]]; then
    sed -i 's@root /var/www/html/;@'"root /var/www/html/${NGINX_DOCROOT};"'@' /etc/nginx/conf.d/*.conf
fi

# Ensure server name defined.
if [[ -z "$NGINX_SERVER_NAME" ]]; then
    NGINX_SERVER_NAME=localhost
fi

# Set server name
if [ -n "$NGINX_SERVER_NAME" ]; then
    sed -i 's/SERVER_NAME/'"${NGINX_SERVER_NAME}"'/' /etc/nginx/conf.d/*.conf
fi
if
# Enable Self Signed Cert
DH_SIZE="2048"

DH="/etc/nginx/external/dh.pem"

if [ ! -e "$DH" ]
then
  echo " --  seems like the first start of nginx so generating certs for SSL"
  echo ""
  cp /etc/nginx/external/ssl.conf /etc/nginx/conf.d
  echo " --  generating $DH with size: $DH_SIZE"
  openssl dhparam -out "$DH" $DH_SIZE 
fi

if [ ! -e "/etc/nginx/external/cert.pem" ] || [ ! -e "/etc/nginx/external/key.pem" ]
then
  echo " --  generating self signed cert"
  openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=localhost" \
  -keyout "/etc/nginx/external/key.pem" \
  -out "/etc/nginx/external/cert.pem" \
  -days 3650 -nodes -sha256 && \
  cp /etc/nginx/external/*.conf /etc/nginx/conf.d/ 2> /dev/null > /dev/null && \
  echo " --  starting nginx"
  exec nginx -g "daemon off;"
else
  echo " --  only copy /etc/nginx/external/*.conf files to /etc/nginx/conf.d/"
  cp /etc/nginx/external/*.conf /etc/nginx/conf.d/ 2> /dev/null > /dev/null && \
  echo " --  starting nginx"
  exec nginx -g "daemon off;"
fi




