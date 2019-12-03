#/bin/sh
echo "Script W0rking"
timedatectl set-timezone America/New_York
echo "time set to America/New_york:"
timedatectl | grep "Time"
hostnamectl set-hostname $1
hostnamectl
sudo apt-get install -y apache2
apache2 -version
sudo ufw allow 'Apache'
sudo /lib/systemd/systemd-sysv-install enable apache2
curl -XGET http://$(hostname -I)
sudo mkdir -p /var/www/sampledomain.com/html
sudo chown -R $USER:$USER /var/www/sampledomain.com/html
sudo chmod -R 755 /var/www/sampledomain.com
echo "<html>
<head>
<title>Welcome to the page sampledomain.com!</title>
</head>
<body>
<h1>You got Lucky! Your sampledomain.com server block is up!</h1>
</body>
</html>" > /var/www/sampledomain.com/html/index.html
sudo touch /etc/apache2/sites-available/sampledomain.com.conf
sudo chown -R $USER:$USER /etc/apache2/sites-available/sampledomain.com.conf
sudo echo """<VirtualHost *:80>
ServerAdmin admin@sampledomain.com
ServerName sampledomain.com
ServerAlias www.sampledomain.com
DocumentRoot /var/www/sampledomain.com/html
ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>""" > /etc/apache2/sites-available/sampledomain.com.conf

sudo unlink /etc/apache2/sites-enabled/000-default.conf
sudo ln -s /etc/apache2/sites-available/sampledomain.com.conf /etc/apache2/sites-enabled/
sudo service apache2 reload
sudo /etc/init.d/apache2 restart
echo "ServerName sampledomain.com" | sudo tee /etc/apache2/conf-available/servername.conf
sudo a2enconf servername
sudo apache2ctl -t
curl -Iv http://sampledomain.com
sudo apt-get install libopenscap8
#129.10.0.0/16
#155.33.0.0/16
#204.167.52.0/24
