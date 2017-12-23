#!/bin/bash

export AWS_PATH=/opt/aws
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre

/opt/aws/bin/ec2-associate-address -i $(curl http://169.254.169.254/latest/meta-data/instance-id) -a $EIP_ID

CREDS_PATH=/etc/creds
mkdir -p $CREDS_PATH

curl -L https://raw.githubusercontent.com/gilt/kms-s3/master/install | /bin/bash
/usr/local/bin/kms-s3 -s $CREDS_BUCKET_URI/$CREDS_BUNDLE_PATH -f creds.tar.gz get
tar -C $CREDS_PATH -xvzf creds.tar.gz

if [ -n "$ADDITIONAL_SCRIPT" ] ; then
  source "$ADDITIONAL_SCRIPT"
fi;

BASE_PARAMS="-d --restart=always"

docker run $BASE_PARAMS --name openvpn-main-1194 \
           -v $CREDS_PATH/openvpn-main:/etc/openvpn/keys \
           -p 1194:1194/udp \
           --privileged \
           michae1t/openvpn

