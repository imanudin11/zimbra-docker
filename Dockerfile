#################################################################
# Dockerfile for Zimbra Ubuntu
# Based on Ubuntu 20.04
# Created by Darnel Hunter
#################################################################
FROM ubuntu:20.04
MAINTAINER Darnel Hunter <dhunter@innotel.us>

ARG DEBIAN_FRONTEND=noninteractive


## Set Local Repos

# Update and Upgrade Ubuntu
RUN     apt-get update -y && \
        apt-get upgrade -y && apt-get install sudo -y

# Install dependencies
RUN apt-get install -y gcc make g++ openssl libxml2-dev wget nano perl libnet-ssleay-perl libauthen-pam-perl libio-pty-perl unzip shared-mime-info curl cron

#Install Webmin
RUN cd /usr/src
RUN wget http://download.webmin.com/devel/deb/webmin_current.deb
RUN dpkg -i webmin_current.deb
RUN apt-get -fy install

# Download dns-auto.sh
RUN curl -k https://raw.githubusercontent.com/imanudin11/zimbra-docker/master/dns-auto.sh > /srv/dns-auto.sh
RUN chmod +x /srv/dns-auto.sh

# Copy rsyslog services
RUN curl -k https://raw.githubusercontent.com/imanudin11/zimbra-docker/master/rsyslog > /etc/init.d/rsyslog
RUN chmod +x /etc/init.d/rsyslog

# Crontab for rsyslog
RUN (crontab -l 2>/dev/null; echo "1 * * * * /etc/init.d/rsyslog restart > /dev/null 2>&1") | crontab -

# Startup service
RUN echo 'cat /etc/resolv.conf > /tmp/resolv.ori' > /services.sh
RUN echo 'echo "nameserver 127.0.0.1" > /tmp/resolv.add' >> /services.sh
RUN echo 'cat /tmp/resolv.add /tmp/resolv.ori > /etc/resolv.conf' >> /services.sh
RUN echo '/etc/init.d/bind9 restart' >> /services.sh
RUN echo '/etc/init.d/rsyslog restart' >> /services.sh
#RUN echo '/etc/init.d/zimbra restart' >> /services.sh
RUN chmod +x /services.sh

# Entrypoint
ENTRYPOINT /services.sh && /bin/bash
