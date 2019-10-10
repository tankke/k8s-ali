#!/bin/bash
config()
{
export KUBE_APISERVER="https://10.7.20.216:6443"
export NODE_NAMES=(node01 node02 node03 node04 node05 node06 node07 node08 node09 node10)

for node_name in ${NODE_NAMES[@]}
  do
    echo ">>> ${node_name}"

    # 创建 token
    export BOOTSTRAP_TOKEN=$(kubeadm token create \
      --description kubelet-bootstrap-token \
      --groups system:bootstrappers:${node_name} \
      --kubeconfig ~/.kube/config)

    # 设置集群参数
    kubectl config set-cluster kubernetes \
      --certificate-authority=/etc/kubernetes/ssl/ca.pem \
      --embed-certs=true \
      --server=${KUBE_APISERVER} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置客户端认证参数
    kubectl config set-credentials kubelet-bootstrap \
      --token=${BOOTSTRAP_TOKEN} \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置上下文参数
    kubectl config set-context default \
      --cluster=kubernetes \
      --user=kubelet-bootstrap \
      --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig

    # 设置默认上下文
    kubectl config use-context default --kubeconfig=kubelet-bootstrap-${node_name}.kubeconfig
  done
}

copy-config()
{
  NODE_NAMES=(node01 node02 node03 node04 node05 node06 node07 node08 node09 node10)
  for node_name in ${NODE_NAMES[@]}
  do
    echo ">>> ${node_name}"
    scp -P 2122 kubelet-bootstrap-${node_name}.kubeconfig root@${node_name}:/etc/kubernetes/kubelet-bootstrap.kubeconfig
  done
}

##配置 kubelet.kubeconfig并复制至所有 node 节点
LOCAL_IP=`ip addr|grep eth0|grep inet|awk -F "[/ ]+" '{print $3}'`
MASTER1='10.7.20.200'
if [ $LOCAL_IP == $MASTER1 ];
then
    config
    copy-config
fi
