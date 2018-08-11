#!/bin/bash

OSVER=`lsb_release -c | awk '{print $2}'`
sudo cat >/etc/apt/sources.list <<EOL0
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER} main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-backports main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-proposed main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-security main multiverse restricted universe
deb http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-updates main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER} main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-backports main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-proposed main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-security main multiverse restricted universe
deb-src http://mirrors.ustc.edu.cn/ubuntu-ports/ ${OSVER}-updates main multiverse restricted universe
EOL0

mkdir -p ~/.pip/
cat >~/.pip/pip.conf <<EOL
[global]
trusted-host =  mirrors.aliyun.com
index-url = http://mirrors.aliyun.com/pypi/simple
EOL


