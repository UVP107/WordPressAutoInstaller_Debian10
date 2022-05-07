# WordPressAutoInstaller_Debian10

How to run?
Make sure you have entered superuser mode, then :

```
chmod a+x install.sh
```
```
./install.sh
```
To uninstall you can use :

```
chmod a+x uninstaller.sh
```
```
./uninstalller.sh
```
If you encounter an error "ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (111)" or your mysql.sock are missing try this :

```
/etc/init.d/mysqld_safe
```
Tested on Debian 10 and Debian 11
