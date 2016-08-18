#!/bin/sh

# Install dependensi
echo "Installing dependencies..."
yum install -y wget

# assign variable from user input
# exchange log karena script ini hanya digunakan untuk mengirim log ke rabbitmq
echo "assign variable"
if [$1 == ""]; then
	read -p "RabbitMQ host: " -e host
	read -p "RabbitMQ vhost: " -e vhost
	read -p "RabbitMQ user: " -e user
	read -p "RabbitMQ password: " -e password
else
	host=$1
	vhost=$2
	user=$3
	password=$4
fi
exchange=log
queue=$(hostname)
durable=true 		# ganti false jika diinginkan

# Download all script
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/install-jdk.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/install-logstash.sh
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/script/add_exchange_queue.sh

# Get exec permission
chmod +x install-jdk.sh
chmod +x install-logstash.sh
chmod +x add_exchange_queue.sh

# Install JDK
echo "Installing Oracle JDK..."
./install-jdk.sh

# Install rabbitmqadmin untuk menambah exchange dan queue
echo "Install rabbitmqadmin"
wget -q "http://$host:15672/cli/rabbitmqadmin"
chmod +x rabbitmqadmin
mv rabbitmqadmin /usr/bin

# Install Logstash and set logstash user as root
echo "Installing logstash and set logstash user as root..."
./install-logstash.sh
sed -i '/#LS_USER=logstash/a LS_USER=root' /etc/sysconfig/logstash

echo "Downloading logstash input config"
wget -q https://raw.githubusercontent.com/akhfa/Dist_IDS/master/config/cluster/01-sqi-input.conf

# Menambahkan exchange dan queue yang dibutuhkan
./add_exchange_queue.sh $host $vhost $user $password log fanout log
./add_exchange_queue.sh $host $vhost $user $password elastic-true fanout elastic-true
./add_exchange_queue.sh $host $vhost $user $password elastic-false fanout elastic-false
./add_exchange_queue.sh $host $vhost $user $password pattern fanout pattern-$(hostname)

