FROM amazonlinux:2023

# Install dependencies
# shadow-utils.x86_64 is required to create 'mqm' user/group during installation
# net-tools is required for 'netstat' and other commands
RUN yum install tar gzip procps which sudo rpm-build shadow-utils.x86_64 net-tools openssl passwd -y 

# Copy files to image
COPY 9.4.4.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz /tmp/
WORKDIR /tmp/
RUN tar xvf 9.4.4.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz
RUN rm 9.4.4.0-IBM-MQ-Advanced-for-Developers-LinuxX64.tar.gz

## Installation
# https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.2.0/com.ibm.mq.ins.doc/q008640_.htm
WORKDIR /tmp/MQServer 
RUN ./crtmqpkg mqm

WORKDIR /var/tmp/mq_rpms/mqm/x86_64/
RUN rpm -Uvh MQSeries*.rpm

# Accept License
# https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.2.0/com.ibm.mq.ins.doc/q133540_.htm#q133540_
WORKDIR /opt/mqm/bin/
RUN ./mqlicense <<< "1"

# Verification
# https://www.ibm.com/support/knowledgecenter/SSFKSJ_9.2.0/com.ibm.mq.ins.doc/q009243_.htm
RUN sudo -u mqm ./dspmqver

EXPOSE 9443 1414 9157

RUN groupadd -g 1002 dev
RUN useradd -rm -d /home/app -s /bin/bash -g dev -G dev -u 101 app -p $(echo passw0rd | openssl passwd -1 -stdin)

# Configure MQ Web Console
COPY install/mqwebuser.xml /var/mqm/web/installations/Installation1/servers/mqweb
RUN chown mqm:mqm /var/mqm/web/installations/Installation1/servers/mqweb/mqwebuser.xml
RUN chmod 640 /var/mqm/web/installations/Installation1/servers/mqweb/mqwebuser.xml
RUN sudo -u mqm /opt/mqm/bin/strmqweb

# Start Queue Manager & Web script
COPY install/run_mq.sh /opt/mqm/bin/run_mq.sh
RUN chmod +x /opt/mqm/bin/run_mq.sh
RUN chown mqm:mqm /opt/mqm/bin/run_mq.sh

# Install & Configure Queue Manager
COPY install/xdevmq_init.mqsc /tmp/xdevmq_init.mqsc
RUN sudo chown mqm:mqm /tmp/xdevmq_init.mqsc 
RUN mkdir /mnt/mqm || true
RUN mkdir /mnt/mqm/data || true 
RUN mkdir /mnt/mqm/logs || true
RUN chown mqm:mqm /mnt/mqm || true
RUN chown mqm:mqm /mnt/mqm/data || true
RUN chown mqm:mqm /mnt/mqm/logs || true

COPY install/install_mq.sh /tmp/install_mq.sh
WORKDIR /opt/mqm/bin/
RUN sh /tmp/install_mq.sh
#RUN sudo -u mqm /opt/mqm/bin/crtmqm -md /mnt/mqm/data -ld /mnt/mqm/logs QM1
#RUN sudo -u mqm /opt/mqm/bin/strmqm -x -d all QM1 
#RUN sudo -u mqm /opt/mqm/bin/dspmq
# RUN sudo -u mqm /opt/mqm/bin/runmqsc QM1 -f /tmp/xdevmq_init.mqsc

#ENTRYPOINT [ "sh", "/opt/mqm/bin/run_mq.sh" ]

# Install Queue Manager
#COPY install/install_mq.sh /tmp/install_mq.sh
#COPY install/xdevmq_init.mqsc /tmp/xdevmq_init.mqsc
#WORKDIR /opt/mqm/bin/
#RUN sh /tmp/install_mq.sh

# Configure Queue Manager
#COPY xdevmq_init.mqsc /tmp/xdevmq_init.mqsc
#WORKDIR /opt/mqm/bin/
#RUN sh /opt/mqm/bin/runmqsc XDEVMQ < /tmp/xdevmq_init.mqsc