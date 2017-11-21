# openvpn
cd ~/openvpn/
openvpn rtr-znn3i90d.ovpn > /dev/null &

# hproxy
# mkdir /run/haproxy
haproxy -f /etc/haproxy/haproxy.cfg -D -p /var/run/haproxy.pid

# nginx
nginx -s reload

# jenkins
# cd /opt/
# chmod 777 -R jenkins
docker restart jenkins

# redis
service redis-server restart

# mysql
service mysql restart

# tomcat
service anitama-app restart

# nodejs
pm2 kill
cd /doremi/
npm start
