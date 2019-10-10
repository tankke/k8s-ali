#!/bin/bash
config()
{
export ENCRYPT_KEY=$(head -c 32 /dev/urandom | base64)

cat <<EOF > /etc/kubernetes/encrypt-data.yaml
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: ${ENCRYPT_KEY}
    - identity: {}
EOF
}

##配置加密数据
##复制至其他master
LOCAL_IP=`ip addr|grep eth0|grep inet|awk -F "[/ ]+" '{print $3}'`
MASTER1='10.7.20.200'
if [ $LOCAL_IP == $MASTER1 ];
then
    config
    for n in master02 master03
    do
      scp -P 2122 /etc/kubernetes/encrypt-data.yaml root@$n:/etc/kubernetes/
    done
fi
