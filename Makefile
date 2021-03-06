USERNAME := $(shell id -nu)

init:
	sudo make prepare && \
	sudo make vmware-tool

# with sudo
prepare:
	systemctl disable firewalld && \
	systemctl stop firewalld && \
	yum install -y ansible wget && \
	cd /etc/yum.repos.d && mkdir repo_bak && \
	mv *.repo repo_bak/ && wget http://mirrors.aliyun.com/repo/Centos-7.repo && \
	wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
	yum clean all && yum makecache	

# with sudo
vmware-tool:
	mkdir /mnt/cdrom && mount /dev/cdrom /mnt/cdrom && \
	cd /tmp && tar zxpf /mnt/cdrom/VMwareTools-10.1.15-6627299.tar.gz && umount /dev/cdrom && \
	cd vmware-tools-distrib && ./vmware-install.pl

# prepare ./hosts ./project/develop/inventory/vars/develop youcompleteme
# youcompleteme支持c/c++/c#需要添加参数--clang-completer
vmware:
	ansible-playbook ./project/develop/playbook/system.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/shadowsocket.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/vim.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/go.yml -i ./hosts -e "group=develop" -K -k && \
    /bin/bash ~/src/personal_tool_conf/oh-my-zsh-install.sh && \
	ansible-playbook ./project/develop/playbook/zsh.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/angular.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/vim-plugin.yml -i ./hosts -e "group=develop" -K -k && \
    python3 ~/.vim/bundle/YouCompleteMe/install.py --gocode-completer --tern-completer && \
	ansible-playbook ./project/develop/playbook/fzf.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/tmux.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/docker.yml -i ./hosts -e "group=develop" -K -k

plugin:
	vim +PluginInstall +qall && \
	vim +GoInstallBinaries +qall

basic:
	ansible-playbook ./project/develop/playbook/basic.yml -i ./hosts -e "group=develop" -K -k

# kube
k8s-dev-master:
	ansible-playbook ./project/k8s-dev/playbook/system.yml -i ./hosts -e "group=master" -K -k && \
	ansible-playbook ./project/k8s-dev/playbook/docker.yml -i ./hosts -e "group=master" -K -k && \
	ansible-playbook ./project/k8s-dev/playbook/onekube.yml -i ./hosts -e "group=master" -K -k && \
	rm -rf ~/.kube && mkdir ~/.kube && \
	ansible-playbook ./project/k8s-dev/playbook/local.yml -i ./hosts -e "group=master" -K -k

k8s-dev-node:
	ansible-playbook ./project/k8s-dev/playbook/system.yml -i ./hosts -e "group=node" -K -k && \
	ansible-playbook ./project/k8s-dev/playbook/docker.yml -i ./hosts -e "group=node" -K -k && \
	ansible-playbook ./project/k8s-dev/playbook/node.yml -i ./hosts -e "group=node" -K -k

kube-dev-basic:
	ansible-playbook ./project/k8s-dev/playbook/basic.yml -i ./hosts -e "group=node" -K -k
