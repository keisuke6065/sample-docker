#!/bin/bash
#mkdir -p /etc/ecs/
#echo ECS_CLUSTER=sample-cluster >> /etc/ecs/ecs.config
#sudo yum install -y docker
#curl -L "https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#sudo chmod +x /usr/local/bin/docker-compose
#sudo usermod -a -G docker jenkins
#sudo service docker start
echo user data start
/sbin/mkfs.ext4 /dev/xvdf
/bin/mkdir -p /var/jenkins
/bin/cp /etc/fstab /etc/fstab.orig
echo '/dev/xvdf  /var/jenkins ext4    defaults,nofail 0   0' >> /etc/fstab
/bin/mount -t ext4 /dev/xvdf /var/jenkins
echo user data end