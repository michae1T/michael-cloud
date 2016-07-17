#!/bin/bash

PACKAGE=$1
PACKAGE_NAME=$2

UHOME=/home/ec2-user/
UUSER=ec2-user

mkdir -p $UHOME
aws s3 cp s3://michael-credentials/ssh/authorized_keys $UHOME/.ssh
chmod 700 $UHOME/.ssh
chown 600 $UHOME/.ssh/authorized_keys
chown -R $UUSER:$UUSER $UHOME/.ssh

mkdir /mnt/data
mount --bind /mnt/data /mnt/data
mount --make-shared /mnt/data

yum -y update
yum -y install docker fuse

service docker enable
service docker start

aws s3 cp $PACKAGE/init-${PACKAGE_NAME}.sh .
exec bash init-${PACKAGE_NAME}.sh




