# Penambahan Warna 
kuning="\033[1;33m"
biru="\033[1;36m"
e="\033[0m"

echo -e $kuning"Pastikan anda telah masuk sebagai root"$e
sleep 3
echo -e $biru"Mengistall Package yang diperlukan..."$e

# Install MariaDB
echo -e $biru "Menginstall MariaDB"$e
apt install mariadb-client mariadb-server -y

# Install Apache
echo -e $biru"Menginstall Apache2"$e
apt install apache2 unzip -y

# Install Ekstensi PHP
echo -e $biru"Menginstall Ekstensi PHP"$e
apt install php mysql-common php-mysql php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip links -y

# Pembuatan Database
echo -e $kuning"Secure installation untuk MariaDB"
mysql_secure_installation
sleep 1
echo -e $biru"Catat nama database, user, dan password jika perlu"
sleep 1
echo -e $biru"Membuat Database dengan nama $kuning wordpress$e"$e
mysql -u root -e "create database wordpress;show databases;show warnings"
sleep 1
echo -e $biru"Membuat user dengan nama $kuning admin$e dengan password $kuning 123$e"$e
mysql -u root -e "create user 'admin'@'localhost' identified by '123';show warnings"
sleep 1
echo -e $biru"Memberikan akses user $kuning admin$e ke database $kuning wordpress$e"
mysql -u root -e "grant all privileges on wordpress.* to 'admin'@'localhost' identified by '123';flush privileges;show grants for 'admin'@'localhost'"

# Pembuatan WordPress
echo -e $biru"Mendownload WordPress di folder $kuning /var/www/html$e"$e
wget http://wordpress.org/latest.zip
echo -e $biru"Mengekstrak file WordPress"$e
unzip latest.zip
mv -f wordpress/ /var/www/html
echo -e $biru"File WordPress tersimpan di $kuning /var/www/html$e"$e
echo -e $biru"Mengubah kepemilikan dan hak akses wordpress"$e
chmod u=rwx,g=rwx,o=rx /var/www/html/wordpress -R
chown www-data:www-data /var/www/html/wordpress -R
echo -e $biru"Mengatur dokumen root website ke /var/www/html/wordpress"$e
sed -i -e "s%/var/www/html%/var/www/html/wordpress%g" "/etc/apache2/sites-available/000-default.conf"
echo -e $biru "Merestart service Apache2 dan MariaDB"$e
systemctl restart apache2
systemctl restart mariadb
echo -e $biru" Instalasi selesai "$e
