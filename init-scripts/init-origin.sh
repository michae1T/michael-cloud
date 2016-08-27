#!/bin/bash

export AWS_PATH=/opt/aws
export EC2_HOME=/opt/aws/apitools/ec2
export JAVA_HOME=/usr/lib/jvm/jre

/opt/aws/bin/ec2-associate-address -i $(curl http://169.254.169.254/latest/meta-data/instance-id) -a $EIP_ID

# Required for PPTP in containers
modprobe nf_conntrack_pptp nf_conntrack_proto_gre

CREDS_URI=s3://michael-credentials
CREDS_PATH=/etc/creds

mkdir -p $CREDS_PATH/ppp $CREDS_PATH/openvpn-main $CREDS_PATH/openvpn-tor
mkdir -p /etc/s3fs /etc/owncloud /etc/nginx_overrides

sync_openvpn() {
  aws s3 cp $CREDS_URI/openvpn-$1/server.key $CREDS_PATH/openvpn-$1
  aws s3 cp $CREDS_URI/openvpn-$1/ca.crt $CREDS_PATH/openvpn-$1
  aws s3 cp $CREDS_URI/openvpn-$1/dh.pem $CREDS_PATH/openvpn-$1
  aws s3 cp $CREDS_URI/openvpn-$1/server.crt $CREDS_PATH/openvpn-$1
}

aws s3 cp $CREDS_URI/chap-secrets $CREDS_PATH/ppp
sync_openvpn main
sync_openvpn tor
aws s3 cp $CREDS_URI/s3fs/iam_role /etc/s3fs
aws s3 cp $CREDS_URI/s3fs/bucket /etc/s3fs

aws s3 cp $CREDS_URI/owncloud/config.php /etc/owncloud
aws s3 cp $CREDS_URI/owncloud/ca-bundle.crt /etc/owncloud
aws s3 cp $CREDS_URI/owncloud/nginx.conf /etc/nginx_overrides
aws s3 cp $CREDS_URI/owncloud/server.crt /etc/nginx_overrides
aws s3 cp $CREDS_URI/owncloud/server.key /etc/nginx_overrides


wget 'https://raw.githubusercontent.com/michae1T/openvpn-tor-gateway/master/bin/otor-gateway.sh'
mkdir -p /opt/bin
chmod +x otor-gateway.sh
mv otor-gateway.sh /opt/bin
/opt/bin/otor-gateway.sh start $CREDS_PATH/openvpn-tor 1195

BASE_PARAMS="-itd --restart=always"

docker run $BASE_PARAMS --name s3fs \
            --cap-add mknod --cap-add sys_admin \
            --device=/dev/fuse \
            -v /mnt/data:/mnt/data:shared \
            michae1t/s3fs /usr/bin/s3fs -f -o allow_other -o use_cache=/tmp \
                                        -o iam_role=`cat /etc/s3fs/iam_role` \
                                        `cat /etc/s3fs/bucket` /mnt/data

docker run $BASE_PARAMS --name openvpn-main-1194 \
           -v $CREDS_PATH/openvpn-main:/etc/openvpn/keys \
           -p 1194:1194/udp \
           --privileged \
           michae1t/openvpn

docker run $BASE_PARAMS --name pptp-1723 \
           -v $CREDS_PATH/ppp:/etc/creds \
           -p 1723:1723/tcp \
           --privileged \
           michae1t/pptp

docker run $BASE_PARAMS --name owncloud \
           -v /mnt/data:/mnt/data:shared \
           -v /etc/owncloud:/etc/owncloud \
           -v /etc/nginx_overrides:/etc/nginx_overrides \
           -p 80:80/tcp -p 443:443/tcp \
           michae1t/owncloud

