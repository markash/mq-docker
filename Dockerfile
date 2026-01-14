# References
# - https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=imlur-installing-first-mq-installation-linux-using-rpm-command
# - https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=linux-accepting-license-mq
# - https://www.ibm.com/docs/en/ibm-mq/9.4.x?topic=vmil-verifying-local-server-installation-using-command-line-linux
FROM redhat/ubi9-init:latest

# Install dependencies
# shadow-utils.x86_64 & sudo are required to create 'app' user/group during installation
# net-tools is required for 'netstat' and other commands
# rpm-build is required for building rpm packages
RUN yum --setopt=install_weak_deps=0 -y install tar gzip net-tools rpm-build shadow-utils.x86_64 sudo \
                && yum -y update \
                && yum clean all

RUN groupadd -g 1002 dev
RUN useradd -rm -d /home/app -s /bin/bash -g dev -G dev -u 101 app -p $(echo passw0rd | openssl passwd -1 -stdin)

# Copy files to image
COPY 9.4.4.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz /tmp/
WORKDIR /tmp/
RUN tar xvf 9.4.4.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz
RUN rm 9.4.4.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz

## Installation
WORKDIR /tmp/MQServer 
RUN ./crtmqpkg mqm

WORKDIR /var/tmp/mq_rpms/mqm/x86_64/
RUN rpm -Uvh MQSeries*.rpm

# Accept License
WORKDIR /opt/mqm/bin/
RUN ./mqlicense <<< "1"

# Verification
RUN sudo -u mqm /opt/mqm/bin/dspmqver

# Configure MQ Web Console
USER root
COPY install/mqwebuser.xml /var/mqm/web/installations/Installation1/servers/mqweb
RUN chown mqm:mqm /var/mqm/web/installations/Installation1/servers/mqweb/mqwebuser.xml
RUN chmod 640 /var/mqm/web/installations/Installation1/servers/mqweb/mqwebuser.xml
RUN sudo -u mqm /opt/mqm/bin/strmqweb

# Install & Configure Queue Manager
COPY install/xdevmq_init.mqsc /tmp/xdevmq_init.mqsc
RUN chown mqm:mqm /tmp/xdevmq_init.mqsc 
RUN mkdir /mnt/mqm || true
RUN mkdir /mnt/mqm/data || true 
RUN mkdir /mnt/mqm/logs || true
RUN chown mqm:mqm /mnt/mqm || true
RUN chown mqm:mqm /mnt/mqm/data || true
RUN chown mqm:mqm /mnt/mqm/logs || true

COPY install/install_mq.sh /tmp/install_mq.sh
WORKDIR /opt/mqm/bin/
RUN sh /tmp/install_mq.sh

COPY install/ibmmq.service /etc/systemd/system/ibmmq.service
COPY install/mqweb.service /etc/systemd/system/mqweb.service
RUN chmod -x /etc/systemd/system/ibmmq.service && \
    chmod -x /etc/systemd/system/mqweb.service && \
    systemctl enable ibmmq && \
    systemctl enable mqweb

EXPOSE 9443 1414 9157

CMD [ "/sbin/init" ]