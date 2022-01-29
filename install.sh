# Penambahan Warna 
kuning="\033[1;33m"
biru="\033[1;36m"
e="\033[0m"

echo -e $kuning"Pastikan anda telah masuk sebagai root dan mengetahui ip address pada interface utama"$e
sleep 5
echo -e $biru"Mengistall Package yang diperlukan..."$e

# Install MariaDB
echo -e $biru "Menginstall MariaDB"$e
apt install mariadb-client mariadb-server -y

# Install Apache
echo -e $biru"Menginstall Apache2"$e
apt install apache2 unzip -y

# Install Ekstensi PHP
echo -e $biru"Menginstall Ekstensi PHP"$e
apt install php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip links -y

# Install DNS
echo -e $biru"Menginstall Bind9 dan dnsutils"$e
apt install bind9 dnsutils -y

# Pembuatan Database
echo -e $kuning"Secure installation untuk MariaDB"
mysql_secure_installation
sleep 1
echo -e $biru"Catat nama database, user, dan password jika perlu"
sleep 1
echo -e $biru"Membuat Database dengan nama $kuning wordpress$e"$e
mysql -u root -e "create database wordpress;show databases"
sleep 1
echo -e $biru"Membuat user dengan nama $kuning admin$e dengan password $kuning 123$e"$e
mysql -u root -e "create user 'admin'@'localhost' identified by '123'"
sleep 1
echo -e $biru"Memberikan akses user $kuning admin$e ke database $kuning wordpress$e"
mysql -u root -e "grant all privileges on wordpress.* to 'admin'@'localhost' identified by '123';flush privileges;show grants for 'admin'@'localhost'"

# Pembuatan WordPress
echo -e $biru"Mendownload WordPress di folder $kuning /var/www/html$e"$e
wget http://wordpress.org/latest.zip
echo -e $biru"Mengekstrak file WordPress"$e
unzip latest.zip
mv -f wordpress/ /var/www/html/
echo "
<?php
define( 'DB_NAME', 'wordpress' );
define( 'DB_USER', 'admin' );
define( 'DB_PASSWORD', '123' );
define( 'DB_HOST', 'localhost' );
define( 'DB_CHARSET', 'utf8' );
define( 'DB_COLLATE', '' );
define( 'AUTH_KEY',         'put your unique phrase here' );
define( 'SECURE_AUTH_KEY',  'put your unique phrase here' );
define( 'LOGGED_IN_KEY',    'put your unique phrase here' );
define( 'NONCE_KEY',        'put your unique phrase here' );
define( 'AUTH_SALT',        'put your unique phrase here' );
define( 'SECURE_AUTH_SALT', 'put your unique phrase here' );
define( 'LOGGED_IN_SALT',   'put your unique phrase here' );
define( 'NONCE_SALT',       'put your unique phrase here' );
$table_prefix = 'wp_';
define( 'WP_DEBUG', false );
if ( ! defined( 'ABSPATH' ) ) {
	define( 'ABSPATH', __DIR__ . '/' );
}
require_once ABSPATH . 'wp-settings.php';
" > /var/www/html/wordpress/wp-config.php
echo -e $biru"Mengubah kepemilikan dan hak akses wordpress"$e
chmod u=rwx,g=rwx,o=r /var/www/html/wordpress -R
chown www-data:www-data /var/www/html/wordpress -R
echo -e $kuning "Masukkan nama domain yang anda inginkan. Contoh uvp107.com :"$e
read domain
echo -e $biru"Nama domain telah diatur ke $kuning$domain$e"
echo "
<VirtualHost *:80>
        ServerName $domain
	ServerAlias www.$domain
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html/wordpress
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > /etc/apache2/sites-available/000-default.conf
echo "Merestart service Apache2"
systemctl restart apache2

# Konfigurasi DNS
echo -e $biru"Menkonfigurasikan DNS"$e
echo -e $kuning"Masukkan IP Address interface utama Anda :"
read IP
echo "nameserver $IP
nameserver 8.8.8.8" > /etc/resolv.conf
echo -e $kuning"Masukkan 3 oktet pertama IP Address secara terbalik, misal ada IP 192.168.3.1 maka masukkan 3.168.192"
read okteta
echo -e $kuning"Masukkan oktet terakhir dari IP Address Anda :"
read oktetb
echo -e $biru"File$kuning db.$okteta$e telah dibuat"$e
echo "
$TTL    604800
@       IN      SOA     $domain. root.$domain. (
                              1         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $domain.
$oktetb	IN      PTR     $domain.
" > /etc/bind/db.$okteta
echo -e $kuning"File$kuning db.$domain$e telah dibuat"$e
echo "
$TTL    604800
@       IN      SOA     $domain. root.$domain. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $domain.
@       IN      A       $IP
" > /etc/bind/db.$domain
echo '
zone "$domain" {
        type master;
        file "/etc/bind/db.$domain";
};

zone "$okteta.in-addr.arpa" {
        type master;
        file "/etc/bind/db.$okteta";
};
' > /etc/bind/named.conf
echo -e $biru"File named.conf telah dibuat"$e
echo -e $biru"File konfigurasi tersimpan di $kuning/etc/bind/db.$domain$e dan $kuning/etc/bind/db.$okteta"$e
sleep 3
echo -e $biru"Merestart bind9"$e
systemctl restart bind9

echo -e $biru" Instalasi selesai "$e
nslookup $IP
nslookup $domain
