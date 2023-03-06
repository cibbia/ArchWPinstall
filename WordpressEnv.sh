#!/bin/bash

# Install Apache, MySQL/MariaDB, PHP, and phpMyAdmin
echo "Installing Apache, MySQL/MariaDB, PHP, and phpMyAdmin..."
sudo pacman -S apache mysql php php-apache phpmyadmin --noconfirm

# Start and enable Apache and MySQL/MariaDB services
echo "Starting and enabling Apache and MySQL/MariaDB services..."
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Reset the root password for MySQL/MariaDB
echo "Resetting the root password for MySQL/MariaDB..."
sudo systemctl stop mysqld
sudo mysqld_safe --skip-grant-tables &
sleep 5
echo "Enter the new root password for MySQL/MariaDB:"
read -s new_password
mysql -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$new_password';
FLUSH PRIVILEGES;
EXIT;
EOF
sudo systemctl stop mysqld

# Create a new WordPress database and user
echo "Creating a new WordPress database and user..."
sudo mysql -u root -p"$new_password" << EOF
CREATE DATABASE wordpress;
GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';
FLUSH PRIVILEGES;
EXIT;
EOF

# Download and install WordPress
echo "Downloading and installing WordPress..."
cd /srv/http/
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* .
sudo rm -rf latest.tar.gz wordpress/

# Update the wp-config.php file with the database details
echo "Updating the wp-config.php file with the database details..."
DB_NAME='wordpress'
DB_USER='wordpressuser'
DB_PASSWORD='password'
DB_HOST='localhost'
WP_CONFIG='/srv/http/wp-config.php'
sed -i "/define('DB_NAME',/a define('DB_USER', '$DB_USER');" $WP_CONFIG
sed -i "/define('DB_NAME',/a define('DB_PASSWORD', '$DB_PASSWORD');" $WP_CONFIG
sed -i "/define('DB_NAME',/a define('DB_HOST', '$DB_HOST');" $WP_CONFIG
sed -i "/define('DB_NAME',/a define('DB_NAME', '$DB_NAME');" $WP_CONFIG

echo "WordPress has been installed successfully!"
