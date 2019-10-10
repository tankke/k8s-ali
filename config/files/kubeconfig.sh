#!/bin/bash
## 配置变量
config()
{
export KUBE_APISERVER="https://10.7.20.216:6443"
cd /root/

## 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} 

## 设置客户端认证参数
kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/ssl/admin.pem \
  --embed-certs=true \
  --client-key=/etc/kubernetes/ssl/admin-key.pem

## 设置关联参数
kubectl config set-context kubernetes \
  --cluster=kubernetes \
  --user=admin

## 设置默认关联
kubectl config use-context kubernetes
}

copy-config()
{
  MASTER=(master01 master02 master03)
  for node_name in ${MASTER[@]}
  do
    echo ">>> ${node_name}"
    scp -P 2122 /root/.kube/config root@${node_name}:/root/.kube/config
  done
}

## 配置 kubeconfig并复制至其他 master
LOCAL_IP=`ip addr|grep eth0|grep inet|awk -F "[/ ]+" '{print $3}'`
MASTER1='10.7.20.200'
if [ $LOCAL_IP == $MASTER1 ];
then
    config
    copy-config
fi
