# 基本使用
* 设置环境变量ANSIBLE_ROOT
* 修改conf目录下的ansible配置，并在根目录下建立软链接
* 在_keys目录下设置对应的ssh key文件，与vault密码

# 使用方式
* ansible-playbook -i project_dir/hosts project_dir/xxx.yml -e 'group=xxx'
