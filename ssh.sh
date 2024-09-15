#!/bin/bash
echo -e "开始安装常用软件"
apt install -y curl
apt install -y wget
apt install -y nano
apt install -y sudo
apt install -y unzip

echo -e "开始设置普通用户sudo权限"
chmod +w /etc/sudoers
echo " august ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo -e "开始设置IPV4转发"
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

echo -e "开始设置关闭IPV6"
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

echo -e "开始设置BBR加速"
echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

echo -e "开始关闭防火墙"
sudo systemctl stop ufw.service
sudo systemctl disable ufw.service
sudo ufw status

echo -e "开始修改密码"
sudo echo root:sbsb12345XX. | chpasswd

echo -e "开始设置ssh登录"
sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service ssh restart


