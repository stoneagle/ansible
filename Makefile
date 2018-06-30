init:
	sudo yum install -y ansible wget && \
	cd /etc/yum.repos.d && mkdir repo_bak && \
	mv *.repo repo_bak/ && wget http://mirrors.aliyun.com/repo/Centos-7.repo && \
	wget -O /etc/yum.repos.d/epel-7.repo http://mirrors.aliyun.com/repo/epel-7.repo && \
	yum clean all && yum makecache	

vmware-tool:
	mkdir /mnt/cdrom && mount /dev/cdrom /mnt/cdrom && \
	cd /tmp && tar zxpf /mnt/cdrom/VMwareTools-10.1.15-6627299.tar.gz && umount /dev/cdrom && \
	cd vmware-tools-distrib && ./vmware-install.pl

# prepare ./hosts ./project/develop/inventory/vars/develop youcompleteme go_pkg.tar
vmware:
	ansible-playbook ./project/develop/playbook/system.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/vim.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/shadowsocket.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/go.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/zsh.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/angular.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/vim-plugin.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/fzf.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/develop/playbook/tmux.yml -i ./hosts -e "group=develop" -K -k && \
	ansible-playbook ./project/docker/playbook/docker.yml -i ./hosts -e "group=develop" -K -k
