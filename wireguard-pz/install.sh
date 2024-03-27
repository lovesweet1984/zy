#!/usr/bin/env bash

echo -e "开始关闭防火墙"
sudo systemctl stop ufw.service
sudo systemctl disable ufw.service
sudo ufw status

echo -e "开始自动安装wirguard"
wget -O wireguard.sh https://get.vpnsetup.net/wg
sudo bash wireguard.sh --auto


echo -e "开始设置wireguard"
sudo systemctl stop wg-quick@wg0.service
sudo curl https://raw.githubusercontent.com/lovesweet1984/zy/main/wireguard-pz/client.conf > /root/client.conf
sudo curl https://raw.githubusercontent.com/lovesweet1984/zy/main/wireguard-pz/1.conf > /root/1.conf
sudo curl https://raw.githubusercontent.com/lovesweet1984/zy/main/wireguard-pz/2.conf > /root/2.conf
sudo curl https://raw.githubusercontent.com/lovesweet1984/zy/main/wireguard-pz/3.conf > /root/3.conf
sudo curl https://raw.githubusercontent.com/lovesweet1984/zy/main/wireguard-pz/wg0.conf > /etc/wireguard/wg0.conf
sudo systemctl restart wg-quick@wg0.service
echo -e "完成设置wirguard"
echo -e "w"


