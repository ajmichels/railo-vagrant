#!/bin/sh

runfile=".runonce.vagrant"
tempdir="/vagrant/.vagrant/temp"

if [ ! -f "${runfile}" ]; then

    if [ ! -d $tempdir ]; then
        mkdir -p "${tempdir}"
    fi

    echo "Installing required software ..."

    # Configure the web server stack.
    export DEBIAN_FRONTEND=noninteractive
    apt-get -qq -y update
    apt-get -qq -y -o dir::cache::archives="${tempdir}" install \
        unzip \
        curl \
        apache2 \
        mysql-server mysql-client > /dev/null 2> /dev/null

    echo "Configuring Apache ..."

    rm -rf /var/www/index.html
    ln -fs /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
    cp -f /vagrant/.vagrant/apache.conf /etc/apache2/sites-enabled/000-default

    echo "Creating a default database ..."
    echo "create database myDatabase" | mysql -u root

    touch "${runfile}"

fi
