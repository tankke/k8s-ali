#!/bin/bash
config()
{
export KUBE_APISERVER="https://10.7.20.216:6443"
cd /etc/kubernetes/

## 设置集群参数
kubectl config set-cluster kubernetes \
  --certificate-authority=/etc/kubernetes/ssl/ca.pem \
  --embed-certs=true \
  --server=${KUBE_APISERVER} \
  --kubeconfig=controller-manager.kubeconfig 

## 设置客户端认证参数
kubectl config set-credentials system:kube-controller-manager \
  --client-certificate=/etc/kubernetes/ssl/controller-manager.pem \
  --client-key=/etc/kubernetes/ssl/controller-manager-key.pem \
  --embed-certs=true \
  --kubeconfig=controller-manager.kubeconfig

## 设置关联参数
kubectl config set-context system:kube-controller-manager \
  --cluster=kubernetes \
  --user=system:kube-controller-manager \
  --kubeconfig=controller-manager.kubeconfig

## 设置默认关联
kubectl config use-context system:kube-controller-manager \
  --kubeconfig=controller-manager.kubeconfig
}

copy-config()
{
  MASTER=(master01 master02 master03)
  for node_name in ${MASTER[@]}
  do
    echo ">>> ${node_name}"
    scp -P 2122 /etc/kubernetes/controller-manager.kubeconfig root@${node_name}:/etc/kubernetes/
  done
}

## 配置 controller-manager.kubeconfig 并复制至其他 master
LOCAL_IP=`ip addr|grep eth0|grep inet|awk -F "[/ ]+" '{print $3}'`
MASTER1='10.7.20.200'
if [ $LOCAL_IP == $MASTER1 ];
then
    config
    copy-config
fi
