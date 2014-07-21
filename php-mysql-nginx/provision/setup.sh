#!/bin/bash

echo "Provisioning virtual machine..."

# Git
echo "Installing Git"
apt-get install git -y > /dev/null

# Nginx
echo "Installing Nginx"
apt-get install nginx -y > /dev/null

# PHP
  # Ubuntu’s APT (Advanced Packaging Tool) database is not always up-to-date
  # with the latest stable PHP version, therefore we need to switch to a
  # different source when installing it. we need to install a couple of tools
  # before we can actually install PHP itself
echo "Updating PHP repository"
apt-get install python-software-properties build-essential -y > /dev/null
add-apt-repository ppa:ondrej/php5 -y > /dev/null
apt-get update > /dev/null

echo "Installing PHP"
apt-get install php5-common php5-dev php5-cli php5-fpm -y > /dev/null

echo "Installing PHP extensions"
apt-get install curl php5-curl php5-gd php5-mcrypt php5-mysql -y > /dev/null

# MySQL
  # Installing MySQL is even trickier, because the installation process will
  # prompt you for the root password, but Vagrant needs to automate the
  # installation and somehow fill in the password automatically. Using the
  # debconf-utils tool we can use this tool to tell the MySQL installation
  # process to stop prompting for a password and use the password from the
  # command line instead (below we set the root password to 1234)
echo "Preparing MySQL"
apt-get install debconf-utils -y > /dev/null
debconf-set-selections <<< "mysql-server mysql-server/root_password password 1234"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password 1234"

# Now we can go ahead and install MySQL without getting the root password prompts
echo "Installing MySQL"
apt-get install mysql-server -y > /dev/null

# Nginx Configuration
echo "Configuring Nginx"
cp /var/www/provision/config/nginx_vhost /etc/nginx/sites-available/nginx_vhost > /dev/null
ln -s /etc/nginx/sites-available/nginx_vhost /etc/nginx/sites-enabled/

rm -rf /etc/nginx/sites-available/default

# Restart Nginx for the config to take effect
service nginx restart > /dev/null

echo "Finished provisioning."
