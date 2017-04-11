# 相关文件
## 通用配置
### docker
1. files目录下，docker-config中存储了auths信息
2. cfssl/docker_certs目录下，存放了目标机器的pem,csr,key.pem
3. cfssl目录下，存放了kube-server的pem,csr,key.pem
4. files目录下，存放了etcd-client的pem,csr,key.pem，以及ca.pem

# 执行顺序
## 第一阶段，机器环境初始化
1. removeDa1.yml 
    * 移除目标机器逻辑卷da1，释放磁盘空间
2. storage/init.yml
    * 重新配置存储结构，调整LVM，创建Docker与GlusterFS thin pool
3. initTool.yml
    * 安装常用系统工具，优化服务器配置，初始化相关目录，启用selinux

## 第二阶段，组件升级
1. upgradeKernel.yml
    * 升级系统内核，重启机器
1. firewall.yml
    * 配置防火墙(cluster未配置，未执行)
1. centosPatch.yml
    * 升级centos版本，重启机器(升级补丁ping不通，未执行)

## 第三阶段，docker相关组件安装
1. certs.yml
    * 配置certs证书(从cmdb上获取，其中ca，kube三个从leader获取)
    * 需要注意权限，部署为search(与etcd,flannel,docker,search等一致)
1. etcd.yml
    * 安装etcd(依赖网桥eth0)
    * 依赖certs文件，生成相应的软链
    * 注意证书的权限，需要与etcd目录，以及系统服务下的执行者一致
    * 需要注意，如果etcd cluster之前启动过，并且member有变动，需要删除data-dir
    * cluster启动时，如果是初次搭建集群，设定为new;如果是加入某个已存在的cluster，则设定为existing
    * 再调用etcdctl时，需要注意ssl验证
    ```
        ./etcd/etcdctl --ca-file ./certs/ca.pem --cert-file ./certs/xxx.pem --key-file ./certs/xxx-key.pem --endpoint "https://XXX:2379" cluster-health
    ```
    * mk /cloud/network/config '{"Network":"172.17.0.0/16"}' 需要存储flannel相关信息
1. flannel.yml
    * 安装flannel(依赖etcd提供的网络配置)
    * 需要根据etcd_prefix获取存储的config
1. docker.yml
    * 安装docker(依赖flannel)
    * 需要在安装并正确启动flannel后执行，docker0的地址在flannel0的子网下
    * docker间可以ping通(未实现)
1. glusterfs.yml
    * 安装glusterfs(只安装了基本的gfs)
1. telegraf.yml
    * 安装telegraf

## 第四阶段，k8s相关组件安装
1. kubernetes.yml
    * 依赖certs文件，生成相应的软链
    * 安装kubernetes(新版本kubernete压缩包，bin的位置不一样，使用的是解压缩后，目录下的kubernetes-server-linux-amd64.tar.gz)
    * master依赖的三个组件，将相关yaml配置放在manifests目录下，启动时会根据hyper容器自动启动
    * kubectl执行https命令 ./kubectl --server=https://XXX --certificate-authority=/data/usr/kubernetes/certs/ca.pem --client-certificate=/data/usr/kubernetes/certs/xxx.pem --client-key=/data/usr/kubernetes/certs/xxx-key.pem get nodes
1. filebeat.yml
    * 配置filebeat的目录(需要配置filebeat_logstash，未安装)
1. skydns.yml
    * 安装skydns(未安装)

## 第五阶段，网络、SELINUX等规则配置
1. acl.yml 
    * 配置acl名单
1. selinux.yml
    * selinux配置(涉及kubelet，docker，flanneld等)



1. 弃用pantheon

