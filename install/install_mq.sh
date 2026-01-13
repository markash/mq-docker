sudo -u mqm /opt/mqm/bin/crtmqm -md /mnt/mqm/data -ld /mnt/mqm/logs QM1
sudo -u mqm /opt/mqm/bin/strmqm -x -d all QM1 
sudo -u mqm /opt/mqm/bin/dspmq
sudo -u mqm /opt/mqm/bin/runmqsc QM1 -f /tmp/xdevmq_init.mqsc
bash