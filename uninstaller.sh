echo "Memulai penghapusan"
apt purge mariadb-client mariadb-server bind9 apache2 php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip links -y
rm -rf /etc/apache2/ /etc/bind/ /var/cache/bind/ /var/www/html /var/bind9 
apt autoremove -y
