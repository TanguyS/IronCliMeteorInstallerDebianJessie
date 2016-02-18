# Deploy Meteor with Iron Cli on Debian Jessie (Apache 2.4)

SERVER
connect with ssh on your server

Install Node
curl -sL https://deb.nodesource.com/setup_0.12 | sudo bash -
apt-get update
sudo apt-get install -y nodejs

Install Apache
sudo apt-get apache2

Activate mod proxy (with proxy_wstunnel for websocket)
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_wstunnel

Set mod proxy on your vhost (replace PORT by the PORT of your install)
  ProxyRequests off
  <Proxy *>
    Require all granted
  </Proxy>

  <Location />
    ProxyPass http://localhost:PORT/
    ProxyPassReverse http://localhost:PORT/
  </Location>

RewriteEngine on
RewriteCond %{HTTP:UPGRADE} ^WebSocket$ [NC]
RewriteCond %{HTTP:CONNECTION} ^Upgrade$ [NC]
RewriteRule .* ws://localhost:PORT%{REQUEST_URI} [P]

Install forever globally
sudo npm install forever -g

Install MongoDB and anything you need

LOCAL
fill your env.sh
export MONGO_URL="YOUR_MONGO_URL"
export PORT=THE_PORT_YOU_USED_BEFORE
export ROOT_URL=YOUR_ROOT_URL

fill your settings.json

Put the file at the root of your iron cli install + make it executable
chmod +x deploy.sh

Launch it, STAGE is for example test or production
./deploy STAGE

It should run now.
