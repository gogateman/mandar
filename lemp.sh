#!/bin/bash

sudo apt-get update -y

count=`dpkg --get-selections | grep nginx | wc -l`

if [ $count -gt 0 ]
then
        echo " ------------NGINX ALREADY PRESENT ----------------------------------------"
        echo " ------------UPDATING TO THE LATEST VERSION IS PRESENT-------------------"

        sudo apt-get remove -y nginx*
        sudo apt-get install -y nginx
        sudo systemctl start nginx
        sudo systemctl enable nginx


        echo " ------------LATEST VERSION OF THE NGINX IS PRESENT -----------------------"
else
        echo "NGINX IS NOT PRESENT..... INSTALLING IT ....................................."

        sudo apt-get install -y nginx
        sudo systemctl start nginx
        sudo systemctl enable nginx
        echo " ----------- NGINX  LATEST VERSION IS NOW INSTALLED ----------------------------------------"
fi

count=`dpkg --get-selections  | grep   "mysql" | wc -l`
echo " count is for mysql $count " 

if [ $count -gt 0 ]
then
        echo " ------------MYSQL ALREADY PRESENT -------------------------------------------"
        echo " ------------ENSURING THAT THE LATEST VERSION  IS PRESENT----------------------"

        sudo apt-get remove -y "mysql*"
        #sudo apt-get -y install mysql-server
        sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mandya4590'
        sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mandya4590'
        sudo apt-get install -y mysql-server
        
        echo " ------------LATEST VERSION OF THE MYSQL IS PRESENT --------------------------"
else
        echo "MYSQL IS NOT PRESENT..... INSTALLING IT ........................................."

        #sudo apt-get -y install mysql-server
        sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password mandya4590'
        sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password mandya4590'
        sudo apt-get install -y  mysql-server
        
        echo " ----------- MYSQL LATEST VERSION IS NOW  INSTALLED --------------------------------------------"
fi

count=`dpkg --get-selections | grep "php" | wc -l`

if [ $count -gt 0 ]
then
        echo " ------------PHP ALREADY PRESENT --------------------------------------------"
        echo " ------------ENSURING THAT THE LATEST VERSION IS PRESENT--------------------"

        sudo apt-get remove -y php*
        sudo apt-get install -y php-fpm php-mysql

        echo " ------------LATEST VERSION OF THE PHP IS PRESENT ---------------------------"
else
        echo "PHP IS NOT PRESENT..... INSTALLING IT ........................................."
                
        sudo apt-get install -y php-fpm php-mysql

        echo " ----------- PHP LATEST VERSION IS NOW INSTALLED ---------------------------------------------"
fi

cp /root/mandar/templates/lemp/php.ini /etc/php/7.0/fpm/php.ini
sudo systemctl restart php7.0-fpm

echo " PLEASE ENTER THE DOMAIN NAME WHICH YOU WANT BELOW"
read dname

sed -i "/${dname}/d"  /etc/hosts

echo "127.0.0.1   $dname"  >> /etc/hosts
cat /etc/hosts

cp /root/mandar/templates/lemp/default /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl reload nginx

echo "-------------------------LEMP INSTALLATION COMPLETED------------------------------------"

E_BADARGS=65
MYSQL=`which mysql`

Q1="CREATE DATABASE IF NOT EXISTS wordpress;"
Q2="GRANT USAGE ON *.* TO wordpressuser@localhost IDENTIFIED BY 'mandya4590';"
Q3="GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost;"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"


#$MYSQL -uroot -p -e "$SQL"
$MYSQL -u root -p'mandya4590' -e "$SQL"

echo "-------------------------MYSQL CONFIGURATION COMPLETED------------------------------------"

cp /root/mandar/templates/word/default /etc/nginx/sites-available/default
sudo nginx -t
sudo systemctl reload nginx

sudo apt-get update -y 
sudo apt-get install -y php-curl php-gd php-mbstring php-mcrypt php-xml php-xmlrpc
sudo systemctl restart php7.0-fpm

cd /tmp
curl -O https://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
cp /tmp/wordpress/wp-config-sample.php /tmp/wordpress/wp-config.php
rm -rf /tmp/latest.tar.gz


mkdir -p /tmp/wordpress/wp-content/upgrade
sudo cp -a /tmp/wordpress /var/www/html

useradd mandar
sudo chown -R mandar:www-data /var/www/html

sudo find /var/www/html -type d -exec chmod g+s {} \;
sudo chmod g+w /var/www/html/wp-content

sudo chmod -R g+w /var/www/html/wp-content/themes
sudo chmod -R g+w /var/www/html/wp-content/plugins

cp /root/mandar/templates/word/wp-config.php /var/www/html/
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> /var/www/html/wp-config.php 

sudo chown -R www-data /var/www/html
sudo chown -R mandar /var/www/html

echo "----------------------- WORDPRESS CONFIGURATION COMPLETED ----------------------------------------------"

