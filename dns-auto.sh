# Configuring DNS Server
echo ""
echo -e "[INFO] : Configuring DNS Server"
sleep 3

DOMAIN=`hostname -d`;
HOSTNAME=`hostname -s`;
IPADDRESS=`hostname -I`;

BIND=`ls /etc/bind/ | grep named.conf.local.back`;

        if [ "$BIND" == "named.conf.local.back" ]; then
        cp /etc/bind/named.conf.local.back /etc/bind/named.conf.local       
        else
        cp /etc/bind/named.conf.local /etc/bind/named.conf.local.back        
        fi


echo 'zone "'$DOMAIN'" IN {' >> /etc/bind/named.conf.local
echo "type master;" >> /etc/bind/named.conf.local
echo 'file "/etc/bind/'db.$DOMAIN'";' >> /etc/bind/named.conf.local
echo "};" >> /etc/bind/named.conf.local

touch /etc/bind/db.$DOMAIN
chgrp bind /etc/bind/db.$DOMAIN


echo '$TTL 1D' > /etc/bind/db.$DOMAIN
echo "@       IN SOA  ns1.$DOMAIN. root.$DOMAIN. (" >> /etc/bind/db.$DOMAIN
echo '                                        0       ; serial' >> /etc/bind/db.$DOMAIN
echo '                                        1D      ; refresh' >> /etc/bind/db.$DOMAIN
echo '                                        1H      ; retry' >> /etc/bind/db.$DOMAIN
echo '                                        1W      ; expire' >> /etc/bind/db.$DOMAIN
echo '                                        3H )    ; minimum' >> /etc/bind/db.$DOMAIN
echo "@         IN      NS      ns1.$DOMAIN." >> /etc/bind/db.$DOMAIN
echo "@         IN      MX      0 $HOSTNAME.$DOMAIN." >> /etc/bind/db.$DOMAIN
echo "ns1       IN      A       $IPADDRESS" >> /etc/bind/db.$DOMAIN
echo "$HOSTNAME IN      A       $IPADDRESS" >> /etc/bind/db.$DOMAIN

sed -i 's/dnssec-validation yes/dnssec-validation no/g' /etc/bind/named.conf.options

# Restart Service & Check results configuring DNS Server

/etc/init.d/bind9 restart
nslookup $HOSTNAME.$DOMAIN
dig $DOMAIN mx
