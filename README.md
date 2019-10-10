
# 使用ansible部署kubernetes集群
---
Master节点
---
+ 10.7.20.200
+ 10.7.20.201
+ 10.7.20.202

内网SLB
---
+ 10.7.20.216
---

Haproxy
---
+ 10.7.21.8
+ 10.7.21.9
---

注: Master节点使用SLB+Haproxy进行高可用负载均衡
+ SLB对HA节点的提供高可用服务
+ Haproxy监听6443并连接kube-apiserver提供负载均衡服务，所有组件通过开放的6443端口访问(即kube-apiserver为192.168.100.180:6443)

---
Node节点
---
+ 10.7.20.203
+ 10.7.20.204
+ 10.7.20.205
+ 10.7.20.206
+ 10.7.20.207
+ 10.7.20.208
+ 10.7.16.204
+ 10.7.21.10
+ 10.7.17.14
+ 10.7.17.15
---
规划
---
1. 使用centos 7.6版本制作
2. 所有节点均部署etcd，版本etcd-v3.3.10
3. 在ansible主机生成ssl证书，并将所有证书放在了/root/ssl下(这里我将所有证书分发至所有节点，但是实际有些证书相应节点并不需要，特此说明)
4. kubernetes二进制包以及压缩后的文件夹均位于/root/下，版本v1.14.0
5. 在node节点部署flannel，版本flannel-v0.11.0
6. haproxy部署在HA节点，版本为haproxy-1.5.18
7. 以上规划都能在k8s.yaml文件上有所体现
---
使用ansible-playbook命令部署集群
---
```bash
# git clone https://github.com/tankke/k8s-ali.git
# mkdir -pv /etc/ansible/roles/
# cp -R ansible-k8s/* /etc/ansible/roles/
# ansible-playbook k8s.yaml
```
---
查看集群状况
---
```bash
# ansible 10.7.20.201 -a "etcdctl --endpoints=https://10.7.20.201:2379 ls /kube/network/subnets"
10.7.20.201 | CHANGED | rc=0 >>
/kube/network/subnets/10.244.57.0-24
/kube/network/subnets/10.244.47.0-24
/kube/network/subnets/10.244.13.0-24
/kube/network/subnets/10.244.85.0-24
/kube/network/subnets/10.244.96.0-24
/kube/network/subnets/10.244.1.0-24
/kube/network/subnets/10.244.44.0-24
/kube/network/subnets/10.244.14.0-24
/kube/network/subnets/10.244.65.0-24
/kube/network/subnets/10.244.4.0-24
# ansible 10.7.20.201 -a "kubectl get cs"
10.7.20.201 | CHANGED | rc=0 >>
NAME                 STATUS    MESSAGE             ERROR
scheduler            Healthy   ok                  
controller-manager   Healthy   ok                  
etcd-0               Healthy   {"health":"true"}   
etcd-1               Healthy   {"health":"true"}   
etcd-2               Healthy   {"health":"true"}
# ansible 10.7.20.201 -a "kubectl get nodes"
10.7.20.201 | CHANGED | rc=0 >>
NAME     STATUS   ROLES    AGE   VERSION
node01   Ready    <none>   35d   v1.14.0
node02   Ready    <none>   34d   v1.14.0
node03   Ready    <none>   34d   v1.14.0
node04   Ready    <none>   34d   v1.14.0
node05   Ready    <none>   34d   v1.14.0
node06   Ready    <none>   34d   v1.14.0
node07   Ready    <none>   34d   v1.14.0
node08   Ready    <none>   34d   v1.14.0
node09   Ready    <none>   34d   v1.14.0
node10   Ready    <none>   34d   v1.14.0
