#!/bin/bash

# This script creates virtual hosts and prepares your mysql DB and drupal directory.
# you should put it under /usr/local/bin/
# and run it with sudo newsite

# Set the path to your localhost
www=/var/www
echo "Enter directory name under $www"
read sn


# Prepare settings.php
chmod '777' $www/$sn/sites/default
cp $www/$sn/sites/default/default.settings.php $www/$sn/sites/default/settings.php
chmod '777' $www/$sn/sites/default/settings.php


# Create a database
sn2=`echo $sn|tr '-' '_'`
mysql -uroot -e "create database $sn2"
echo "Creating new mysql database under $sn2"

# Create the file with VirtualHost configuration in /etc/apache2/site-available/
echo "<VirtualHost *:80>
        DocumentRoot /var/www/$sn/
        ServerName $sn.lh
        <Directory /var/www/$sn/>
                Options +Indexes +FollowSymLinks +MultiViews +Includes
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$sn.conf


# Add the host to the hosts file
echo 127.0.0.1 $sn.lh >> /etc/hosts


# Enable the site
a2ensite $sn


# Reload Apache2
/etc/init.d/apache2 restart

echo "Your new site is available at http://$sn.lh"
