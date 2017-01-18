#!/bin/bash

export AWS_PATH=/opt/aws
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre

/opt/aws/bin/ec2-associate-address -i $(curl http://169.254.169.254/latest/meta-data/instance-id) -a $EIP_ID

# Required for PPTP in containers
modprobe nf_conntrack_pptp nf_conntrack_proto_gre

CREDS_URI=s3://michael-credentials
CREDS_PATH=/etc/creds

mkdir -p $CREDS_PATH/openvpn-main $CREDS_PATH/openvpn-tor
mkdir -p /etc/s3fs /etc/nextcloud

sync_openvpn() {
  aws s3 cp --recursive $CREDS_URI/openvpn-$1/ $CREDS_PATH/openvpn-$1
}

sync_openvpn main
sync_openvpn tor
aws s3 cp --recursive $CREDS_URI/s3fs/ /etc/s3fs

aws s3 cp --recursive $CREDS_URI/nextcloud/ /etc/nextcloud
mv /etc/nextcloud/nginx_overrides /etc/nginx_overrides


wget 'https://raw.githubusercontent.com/michae1T/openvpn-tor-gateway/master/bin/otor-gateway.sh'
mkdir -p /opt/bin
chmod +x otor-gateway.sh
mv otor-gateway.sh /opt/bin
/opt/bin/otor-gateway.sh start $CREDS_PATH/openvpn-tor 1195

BASE_PARAMS="-d --restart=always"

docker run $BASE_PARAMS --name openvpn-main-1194 \
           -v $CREDS_PATH/openvpn-main:/etc/openvpn/keys \
           -p 1194:1194/udp \
           --privileged \
           michae1t/openvpn

docker run $BASE_PARAMS --name nextcloud \
            --cap-add mknod --cap-add sys_admin --device=/dev/fuse \
           -v /etc/nextcloud:/etc/nextcloud \
           -v /etc/nginx_overrides:/etc/nginx_overrides \
           -e S3FS_IAM_ROLE=`cat /etc/s3fs/iam_role` \
           -e S3FS_S3_BUCKET=`cat /etc/s3fs/bucket` \
           -p 80:80/tcp -p 443:443/tcp \
           michae1t/nextcloud

