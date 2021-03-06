#!/bin/sh

# environment variables

HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
FQDN="${HOSTNAME}.${DOMAIN}"
SERVER_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
REV_IP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'|awk -F. '{print $3"."$2"."$1}')
REV_LAST=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'|awk -F. '{print $4}')

# Display variables for debugging

echo hostname - $HOSTNAME
echo domain - $DOMAIN
echo fqdn - $FQDN
echo server IP - $SERVER_IP
echo arp - $REV_IP

echo "Enable/disable other services"
# Disable SMTP
service postfix stop
service sendmail stop
service sshd start
service crond start
service rsyslog start

echo "Host file"
cat /etc/hosts

# echo "Configure DNS for ${HOSTNAME}.${DOMAIN}"
# /setup_dns.sh


INST_FILE=zcs-8.7.7_GA_1787.RHEL6_64.20170410133400.tgz
echo "Checking zimbra installer for CentOS...${INST_FILE}"
if [ ! -f /${INST_FILE} ]; then
	echo "Downloading from source..."
	wget -O /${INST_FILE} http://files2.zimbra.com/downloads/8.7.7_GA/${INST_FILE}
fi

if [ -f /${INST_FILE} ]; then
	echo "Extracting installer...${INST_FILE}"
	tar -xzvf /${INST_FILE} -C /
else
	echo "Zimbra installer not found!"
	exit 1
fi


echo "Host file"
cat /etc/hosts

echo "Install ZIMBRA"

if [ -d "/opt/zimbra" ]; then
	echo "Zimbra have data"
        mv /opt/zimbra/data /opt/databackup
        mv /opt/zimbra/conf /opt/confbackup
        touch /opt/alreadyexist
	echo "========================"
	cd /zcs-* && ./install.sh -s --platform-override < /install_override_exists
        rm -r /opt/zimbra/data
        mv /opt/databackup /opt/zimbra/data && chown -R zimbra:zimbra /opt/zimbra/data
        rm -r /opt/zimbra/conf
        mv /opt/confbackup /opt/zimbra/conf && chown -R zimbra:zimbra /opt/zimbra/data
        mv /opt/
        cd /opt/zimbra && /opt/zimbra/libexec/zmfixperms --extended
        chown -R zimbra:zimbra /opt/zimbra/.ssh
	echo "========================"
else
	cd /zcs-* && ./install.sh --platform-override < /install_override
	echo "========================"
fi

echo "Create zimbra config from configmap"
envsubst < /etc/config/zimbra.conf > /zimbra_config_generated

echo "Zimbra config dump"
cat /zimbra_config_generated

echo "Configure Zimbra"
/opt/zimbra/libexec/zmsetup.pl -c /zimbra_config_generated


echo "Fix rsyslog"
cat <<EOF >> /etc/rsyslog.conf
\$ModLoad imudp
\$UDPServerRun 514
EOF
service rsyslog restart

echo "Fix RED status"
/opt/zimbra/libexec/zmsyslogsetup
killall -HUP rsyslogd 2> /dev/null || true

echo "Run zmupdatekeys as zimbra"
su -c /opt/zimbra/bin/zmupdateauthkeys zimbra

echo "Restart Zimbra"
service zimbra restart

echo "Update LDAP Password"
su -c "/opt/zimbra/bin/zmldappasswd -r ${PASSWORD}" -s /bin/sh zimbra
su -c "/opt/zimbra/bin/zmldappasswd -a ${PASSWORD}" -s /bin/sh zimbra
su -c "/opt/zimbra/bin/zmldappasswd -p ${PASSWORD}" -s /bin/sh zimbra
su -c "/opt/zimbra/bin/zmldappasswd ${PASSWORD}" -s /bin/sh zimbra
su -c "/opt/zimbra/bin/zmlocalconfig -e ldap_bes_searcher_password=${PASSWORD}" -s /bin/sh zimbra
su -c "/opt/zimbra/bin/zmlocalconfig -e ldap_nginx_password=${PASSWORD}" -s /bin/sh zimbra

echo "Restart CROND"
service crond restart

echo "Server is ready..."
if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi
