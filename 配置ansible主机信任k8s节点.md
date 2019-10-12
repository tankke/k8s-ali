---
安装Ansible
---
```bash
# yum -y install ansible
# cat /etc/ansible/hosts | egrep -v "^#|^$"
[ha]
10.7.21.8
10.7.21.9
[master]
10.7.20.200
10.7.20.201
10.7.20.202
[node]
10.7.20.203
10.7.20.204
10.7.20.205
10.7.20.206
10.7.20.207
10.7.20.208
10.7.16.204
10.7.21.10
10.7.17.14
10.7.17.15
[store]
10.7.20.209
10.7.20.210
10.7.20.211

[all:vars]
ansible_ssh_port=2122
```
---
生成SSH认证所需的公钥和私钥文件
---
``` bash
# ssh-keygen -t rsa -P ''
# vim /root/password.txt 
10.7.21.8    artx#@!2019
10.7.21.9    artx#@!2019
10.7.20.200  artx#@!2019
10.7.20.201  artx#@!2019
10.7.20.202  artx#@!2019
10.7.20.203  artx#@!2019
10.7.20.204  artx#@!2019
10.7.20.205  artx#@!2019
10.7.20.206  artx#@!2019
10.7.20.207  artx#@!2019
10.7.20.208  artx#@!2019
10.7.16.204  artx#@!2019
10.7.21.10   artx#@!2019
10.7.17.14   artx#@!2019
10.7.17.15   artx#@!2019
10.7.20.209  artx#@!2019
10.7.20.210  artx#@!2019
10.7.20.211  artx#@!2019
```
---
注:不要留空，不然脚本会认为空白行也是需要执行的，会非正常退出。
---
配置分发密钥的脚本并分发密钥
---
``` bash
# vim pass.sh
#!/bin/bash
##分发秘钥
copy-sshkey()
{
file=/root/password.txt

if [ -e $file ]
then
 echo "---password文件存在,分发秘钥---"
 cat $file | while read line
 do
    host_ip=`echo $line | awk '{print $1}'`
    password=`echo $line | awk '{print $2}'`
    echo "$host_ip"

   /usr/bin/expect << EOF
   set time 20
   spawn ssh-copy-id -i .ssh/id_rsa.pub root@$host_ip
   expect {  
        "(yes/no)?"  
        {  
                send "yes\n"  
                expect "password:" {send "$password\n"}  
        }  
        "*password:"  
        {  
                send "$password\n"  
        }  
    } 
   expect eof  
EOF
 done
else
 echo "---文件不存在---"
fi
}
copy-sshkey

if   [ $? == 0 ]
then
     echo "---脚本正常执行,删除密码文件--- "
     rm -rf $file
else
     echo "---脚本未正常执行--- "
fi
# chmod 755 pass.sh 
# source pass.sh
```
---
在ansible主机配置hosts并复制至所有节点(另:请自行更改各节点hostname主机名)
---
```bash
# vim hosts
###k8s-cluster
10.7.21.8    ha01
10.7.21.9    ha02
10.7.20.200  master01
10.7.20.201  master02
10.7.20.202  master03
10.7.20.203  node01
10.7.20.204  node02
10.7.20.205  node03
10.7.20.206  node04
10.7.20.207  node05
10.7.20.208  node06
10.7.16.204  node07
10.7.21.10   node08
10.7.17.14   node09
10.7.17.15   node10
10.7.20.209  store01
10.7.20.210  store02
10.7.20.211  store03
# ansible all -m copy -a 'src=hosts dest=/etc/'
```
