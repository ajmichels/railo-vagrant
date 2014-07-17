#!/bin/sh

export publicIp=$(/sbin/ifconfig eth1 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')

runfile=".railo.runonce"
tempdir="/vagrant/.vagrant/temp"
railoPassword="**MY_ADMIN_PASSWORD**"
railoInstaller="http://www.getrailo.org/down.cfm?item=/railo/remote/download42/4.2.1.000/tomcat/linux/railo-4.2.1.000-pl2-linux-installer.run&thankyou=false"

if [ ! -f "${runfile}" ]; then

    if [ ! -d $tempdir ]; then
        mkdir -p "${tempdir}"
    fi

    if [ ! -f "${tempdir}/railo-installer.run" ]; then
        echo "Downloading Railo ..."
        wget -q -O "${tempdir}/railo-installer.run" $railoInstaller
    fi

    chmod 744 "${tempdir}/railo-installer.run"

    "${tempdir}/railo-installer.run" \
        --unattendedmodeui minimal \
        --mode unattended \
        --installer-language en \
        --railopass $railoPassword \
        --installiis no > /dev/null

    service railo_ctl stop > /dev/null

    echo "Configuring Railo ..."

    rm -rf /var/www/WEB-INF

    sed -e "s/localhost/$publicIp/g" /vagrant/.vagrant/railo-config/server.xml > temp
    mv temp /opt/railo/tomcat/conf/server.xml

    service railo_ctl start > /dev/null

    echo "Setting Railo Admin password ..."
    curl -s -d "new_password=${railoPassword}&new_password_re=${railoPassword}&lang=en&rememberMe=s&submit=submit" \
        -XPOST http://127.0.0.1/railo-context/admin/server.cfm  > /dev/null

    echo "Adding Datasources, Mappings, etc ..."
    curl -s http://127.0.0.1/.vagrant/railo-config/index.cfm > /dev/null

fi

service apache2 restart > /dev/null

touch "${runfile}"
