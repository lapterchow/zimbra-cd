#!/bin/sh

# environment variables

HOSTNAME=$(hostname -s)
DOMAIN=$(hostname -d)
CONTAINERIP=$(ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/')
RANDOMHAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMSPAM=$(date +%s|sha256sum|base64|head -c 10)
RANDOMVIRUS=$(date +%s|sha256sum|base64|head -c 10)

cat <<EOF > ${1}
AVDOMAIN="default.svc.cluster.local"
AVUSER="admin@default.svc.cluster.local"
CREATEADMIN="admin@default.svc.cluster.local"
CREATEADMINPASS="${PASSWORD}"
CREATEDOMAIN="default.svc.cluster.local"
DOCREATEADMIN=yes
DOCREATEDOMAIN=yes
DOTRAINSA=yes
EXPANDMENU=no
HOSTNAME="${HOSTNAME}.${DOMAIN}"
HTTPPORT=80
HTTPPROXY="TRUE"
HTTPPROXYPORT=8080
HTTPSPORT=443
HTTPSPROXYPORT=8443
IMAPPORT=7143
IMAPPROXYPORT=143
IMAPSSLPORT=7993
IMAPSSLPROXYPORT=993
JAVAHOME=/opt/zimbra/java
LDAPAMAVISPASS="${PASSWORD}"
LDAPPOSTPASS="${PASSWORD}"
LDAPROOTPASS="${PASSWORD}"
LDAPADMINPASS="${PASSWORD}"
LDAPREPPASS="${PASSWORD}"
LDAPBESSEARCHSET=set
LDAPHOST="ldap-0.ldap-service.default.svc.cluster.local"
LDAPPORT=389
LDAPREPLICATIONTYPE=master
LDAPSERVERID=2
MAILBOXDMEMORY=256
MAILPROXY=TRUE
MODE=https
MTAAUTHHOST="mailbox-service.default.svc.cluster.local"
MYSQLMEMORYPERCENT=30
POPPORT=7110
POPPROXYPORT=110
POPSSLPORT=7995
POPSSLPROXYPORT=995
PROXYMODE=https
REMOVE=no
RUNARCHIVING=no
RUNAV=yes
RUNSA=yes
RUNVMHA=no
SMTPDEST="admin@default.svc.cluster.local"
SMTPHOST="mta-service-external.svc.cluster.local"
SMTPNOTIFY=yes
SMTPSOURCE="admin@default.svc.cluster.local"
SNMPNOTIFY=yes
SNMPTRAPHOST="${HOSTNAME}.${DOMAIN}"
SPELLURL="http://${HOSTNAME}.${DOMAIN}:7780/aspell.php"
STARTSERVERS=yes
SYSTEMMEMORY=1.0
TRAINSAHAM="ham@default.svc.cluster.local"
TRAINSASPAM="spam@default.svc.cluster.local"
UPGRADE=yes
USESPELL=yes
VERSIONUPDATECHECKS=TRUE
VIRUSQUARANTINE="virus-quarantine@default.svc.cluster.local"
ZIMBRA_REQ_SECURITY=yes
ldap_bes_searcher_password="${PASSWORD}"
ldap_dit_base_dn_config=cn=zimbra
ldap_nginx_password="${PASSWORD}"
mailboxd_directory=/opt/zimbra/mailboxd
mailboxd_keystore=/opt/zimbra/mailboxd/etc/keystore
mailboxd_keystore_password="${PASSWORD}"
mailboxd_server=jetty
mailboxd_truststore=/opt/zimbra/java/jre/lib/security/cacerts
mailboxd_truststore_password=changeit
postfix_mail_owner=postfix
postfix_setgid_group=postdrop
zimbraClusterType=none
zimbraFeatureBriefcasesEnabled=Disabled
zimbraFeatureTasksEnabled=Enabled
zimbraIPMode=ipv4
zimbraMailProxy="TRUE"
zimbraMtaMyNetworks=127.0.0.0/8 192.168.0.0/24
zimbraPrefTimeZoneId=America/Los_Angeles
zimbraReverseProxyLookupTarget=TRUE
zimbraVersionCheckNotificationEmail="admin@default.svc.cluster.local"
zimbraVersionCheckNotificationEmailFrom="admin@default.svc.cluster.local"
zimbraVersionCheckSendNotifications=TRUE
zimbraWebProxy="TRUE"
zimbra_ldap_userdn=uid=zimbra,cn=admins,cn=zimbra
zimbra_require_interprocess_security=1
INSTALL_PACKAGES="zimbra-apache zimbra-core zimbra-ldap zimbra-logger zimbra-memcached zimbra-mta zimbra-proxy zimbra-snmp zimbra-spell zimbra-store "
EOF
