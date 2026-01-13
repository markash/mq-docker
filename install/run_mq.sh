sudo -u mqm /opt/mqm/bin/strmqweb && sudo -u mqm /opt/mqm/bin/strmqm -x QM1

#export MQSERVER=XDEVMQ.SVRCONN/TCP/'localhost(1414)'
#export MQ_USER="dev01"
#export MQ_PASSWORD="passw0rd"

#export MQSERVER='DEVELOPER/TCP/localhost(1414)'  

#useradd --uid 4000 --groups dev -s /bin/bash --create-home --home-dir /home/dev01 dev01
#usermod --password $(echo passw0rd | openssl passwd -1 -stdin) dev01

#setmqaut -m QM1 -t qmgr -g dev +connect
#setmqaut -m QM1 -n DEV.QUEUE.1 -t q -g dev +get +inq +dsp



#DISPLAY CHLAUTH (XDEV.SVRCONN) MATCH (RUNCHECK) CLNTUSER ('dev01') ADDRESS('172.25.144.1')

#curl -X POST -k --header 'Content-Type: application/json; charset=utf-8' --header 'ibm-mq-rest-csrf-token: abc' -u dev01:passw0rd -d 'Test message from curl command' 'https://127.0.0.1:9443/ibmmq/rest/v1/messaging/qmgr/QM1/queue/DEV.QUEUE.1/message'