#/bin/sh
wget https://raw.githubusercontent.com/akhfa/ta/master/repo/logstash.repo
mv -f logstash.repo /etc/yum.repos.d/
rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
yum -y install logstash