#!/usr/bin/env bash

# This script installs some applications manually, because they're
# not in any repository.

#####################################################
#
#                   Priviledges
#
#####################################################

# Checking for root priviledges: if don't
# have them, recalling this script with sudo
if [[ $EUID -ne 0 ]]; then
    echo 'This script needs to be run as root'
    sudo bash $0 $@
    exit 0
fi

#####################################################
#
#               CPU temp throttle
#
#####################################################

TEMP_THROTTLE_ARCH='temp-throttle.zip'
TEMP_THROTTLE_EXEC='/usr/local/sbin/underclock'

wget 'https://github.com/Sepero/temp-throttle/archive/stable.zip' -O \
    "$TEMP_THROTTLE_ARCH"

# Unzipping only the shellscript to stdout
# and redirecting to /sbin/underclock
unzip -p "$TEMP_THROTTLE_ARCH" '*.sh' > "$TEMP_THROTTLE_EXEC"
chmod +x "$TEMP_THROTTLE_EXEC"
rm "$TEMP_THROTTLE_ARCH"

#####################################################
#
#                      XAMPP
#
#####################################################

XAMPP_INSTALLER='xampp.run'

wget 'https://www.apachefriends.org/xampp-files/5.6.15/xampp-linux-x64-5.6.15-1-installer.run' -O "$XAMPP_INSTALLER"
chmod +x "$XAMPP_INSTALLER"
"./$XAMPP_INSTALLER"
rm "$XAMPP_INSTALLER"

# Basic settings

# Document root
sed -i 's/\/opt\/lampp\/htdocs/\/home\/maze\/Files\/Programming\/WebServers\/Local/g' /opt/lampp/etc/httpd.conf

# PHP settings
PHP_INI='/opt/lampp/etc/php.ini'

sed -i -r 's/.*error_reporting\s*=.+/error_reporting = E_ALL \& ~E_NOTICE \& ~E_WARNING \& ~E_DEPRECATED \& ~E_STRICT/g' $PHP_INI
sed -i -r 's/.*include_path\s*=.+:.*/include_path = ".:\/php\/includes:\/home\/maze\/Files\/Programming\/WebServers\/Local\/util\/php:.\/php:\/home\/maze\/Files\/Programming\/WebServers\/Local\/util\/html"/g' $PHP_INI

# Xdebug settings
PHP_BIN=$(whereis php)
read -a PHP_BIN <<< $PHP_BIN
PHP_BIN=${PHP_BIN[1]}

XAMPP_EXT_DIR=$($PHP_BIN -i | grep -o -P '^extension_dir => .+? =>')
XAMPP_EXT_DIR=${XAMPP_EXT_DIR#'extension_dir => '}
XAMPP_EXT_DIR=${XAMPP_EXT_DIR%' =>'}

PHPIZE=$(whereis phpize)
read -a PHPIZE <<< $PHPIZE
PHPIZE=${PHPIZE[1]}

PHP_CONFIG=$(whereis php-config)
read -a PHP_CONFIG <<< $PHP_CONFIG
PHP_CONFIG=${PHP_CONFIG[1]}

mkdir xdebug
wget -O xdebug/xdebug.tgz http://xdebug.org/files/xdebug-2.4.0rc4.tgz
tar -xzf xdebug/xdebug.tgz -C xdebug
cd xdebug/xdebug*
$PHPIZE
./configure --with-php-config=$PHP_CONFIG
make
cp modules/xdebug.so $XAMPP_EXT_DIR
echo <<BOUND >> $PHP_INI

[zend]
zend_extension=$XAMPP_EXT_DIR/xdebug.so

[xdebug]
xdebug.extended_info=1
xdebug.max_nesting_level=1000
xdebug.profiler_enable = 1
xdebug.profiler_enable_trigger = 1
xdebug.remote_enable=1
xdebug.remote_host=127.0.0.1
xdebug.idekey=netbeans-xdebug
xdebug.remote_port=9000
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_log=/opt/lampp/logs/xdebug.log
xdebug.show_local_vars=1
xdebug.trace_output_dir=/opt/lampp/tmp
xdebug.var_display_max_data=1000
xdebug.var_display_max_depth=1
BOUND
cd - &> /dev/null
rm -rf xdebug

# Apigen
APIGEN_EXEC='/usr/local/bin/apigen'

wget 'http://apigen.org/apigen.phar' -O "$APIGEN_EXEC"
chmod +x "$APIGEN_EXEC"

#####################################################
#
#                   Arduino IDE
#
#####################################################

ARDUINO_ARCH='arduino-ide.tar.xz'

wget 'https://downloads.arduino.cc/arduino-1.6.10-linux64.tar.xz' -O "$ARDUINO_ARCH"
tar -xJf "$ARDUINO_ARCH" -C /opt
rm "$ARDUINO_ARCH"
