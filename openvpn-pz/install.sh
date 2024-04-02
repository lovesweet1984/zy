#!/bin/bash
echo -e "开始自动安装openvpn"
wget -O openvpn.sh https://get.vpnsetup.net/ovpn && sudo bash openvpn.sh --auto

echo -e "开始下载zy项目"
rm -rf /root/zy
git clone https://github.com/lovesweet1984/zy

echo -e "开始修改openvpn的DNS配置"
sudo sed -i 's/8.8.8.8/1.1.1.1/' /etc/openvpn/server/server.conf
sudo sed -i 's/8.8.4.4/1.0.0.1/' /etc/openvpn/server/server.conf

echo -e "开始移动openvpn的配置文件"
cp -r /root/zy/openvpn-pz/server /etc/openvpn


echo -e "重启服务器"
reboot