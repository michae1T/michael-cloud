#!/bin/bash

PACKAGE=$1
PACKAGE_NAME=$2

UHOME=/home/ec2-user/
UUSER=ec2-user

mkdir -p $UHOME
aws s3 cp $CREDS_BUCKET_URI/ssh/authorized_keys $UHOME/.ssh
chmod 700 $UHOME/.ssh
chown 600 $UHOME/.ssh/authorized_keys
chown -R $UUSER:$UUSER $UHOME/.ssh

yum -y update
yum -y install docker

service docker enable
service docker start

aws s3 cp $PACKAGE/init-${PACKAGE_NAME}.sh .
exec bash init-${PACKAGE_NAME}.sh




