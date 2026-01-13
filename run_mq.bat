REM --volume  ./tmp/mq/:/mnt/mqm/
docker run -it --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:rw -p 9443:9443 -p 1414:1414  mq-amazon:latest