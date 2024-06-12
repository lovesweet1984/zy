#!/bin/bash

red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
plain='\033[0m'

cur_dir=$(pwd)

# check root
[[ $EUID -ne 0 ]] && echo -e "${red}Fatal error: ${plain} Please run this script with root privilege \n " && exit 1

# Check OS and set release variable
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    release=$ID
elif [[ -f /usr/lib/os-release ]]; then
    source /usr/lib/os-release
    release=$ID
else
    echo "Failed to check the system OS, please contact the author!" >&2
    exit 1
fi
echo "The OS release is: $release"

arch() {
    case "$(uname -m)" in
    x86_64 | x64 | amd64) echo 'amd64' ;;
    i*86 | x86) echo '386' ;;
    armv8* | armv8 | arm64 | aarch64) echo 'arm64' ;;
    armv7* | armv7 | arm) echo 'armv7' ;;
    armv6* | armv6) echo 'armv6' ;;
    armv5* | armv5) echo 'armv5' ;;
    s390x) echo 's390x' ;;
    *) echo -e "${green}Unsupported CPU architecture! ${plain}" && rm -f install.sh && exit 1 ;;
    esac
}

echo "arch: $(arch)"

os_version=""
os_version=$(grep -i version_id /etc/os-release | cut -d \" -f2 | cut -d . -f1)

if [[ "${release}" == "arch" ]]; then
    echo "Your OS is Arch Linux"
elif [[ "${release}" == "manjaro" ]]; then
    echo "Your OS is Manjaro"
elif [[ "${release}" == "armbian" ]]; then
    echo "Your OS is Armbian"
elif [[ "${release}" == "centos" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red} Please use CentOS 8 or higher ${plain}\n" && exit 1
    fi
elif [[ "${release}" == "ubuntu" ]]; then
    if [[ ${os_version} -lt 20 ]]; then
        echo -e "${red} Please use Ubuntu 20 or higher version!${plain}\n" && exit 1
    fi
elif [[ "${release}" == "fedora" ]]; then
    if [[ ${os_version} -lt 36 ]]; then
        echo -e "${red} Please use Fedora 36 or higher version!${plain}\n" && exit 1
    fi
elif [[ "${release}" == "debian" ]]; then
    if [[ ${os_version} -lt 11 ]]; then
        echo -e "${red} Please use Debian 11 or higher ${plain}\n" && exit 1
    fi
elif [[ "${release}" == "almalinux" ]]; then
    if [[ ${os_version} -lt 9 ]]; then
        echo -e "${red} Please use AlmaLinux 9 or higher ${plain}\n" && exit 1
    fi
elif [[ "${release}" == "rocky" ]]; then
    if [[ ${os_version} -lt 9 ]]; then
        echo -e "${red} Please use Rocky Linux 9 or higher ${plain}\n" && exit 1
    fi
elif [[ "${release}" == "oracle" ]]; then
    if [[ ${os_version} -lt 8 ]]; then
        echo -e "${red} Please use Oracle Linux 8 or higher ${plain}\n" && exit 1
    fi
else
    echo -e "${red}Your operating system is not supported by this script.${plain}\n"
    echo "Please ensure you are using one of the following supported operating systems:"
    echo "- Ubuntu 20.04+"
    echo "- Debian 11+"
    echo "- CentOS 8+"
    echo "- Fedora 36+"
    echo "- Arch Linux"
    echo "- Manjaro"
    echo "- Armbian"
    echo "- AlmaLinux 9+"
    echo "- Rocky Linux 9+"
    echo "- Oracle Linux 8+"
    exit 1

fi

install_base() {
    case "${release}" in
    centos | almalinux | rocky | oracle)
        yum -y update && yum install -y -q wget curl tar tzdata
        ;;
    fedora)
        dnf -y update && dnf install -y -q wget curl tar tzdata
        ;;
    arch | manjaro)
        pacman -Syu && pacman -Syu --noconfirm wget curl tar tzdata
        ;;
    *)
        apt-get update && apt install -y -q wget curl tar tzdata
        ;;
    esac
}

# This function will be called when user installed x-ui out of security
config_after_install() {
           /usr/local/x-ui/x-ui setting -username=sweet4188 -password=love121
        /usr/local/x-ui/x-ui setting -port=41888
}

install_x-ui() {
    cd /usr/local/

    if [ $# == 0 ]; then
        last_version=$(curl -Ls "https://api.github.com/repos/MHSanaei/3x-ui/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
        if [[ ! -n "$last_version" ]]; then
            echo -e "${red}Failed to fetch x-ui version, it maybe due to Github API restrictions, please try it later${plain}"
            exit 1
        fi
        echo -e "Got x-ui latest version: ${last_version}, beginning the installation..."
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-$(arch).tar.gz https://github.com/MHSanaei/3x-ui/releases/download/${last_version}/x-ui-linux-$(arch).tar.gz
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Downloading x-ui failed, please be sure that your server can access Github ${plain}"
            exit 1
        fi
    else
        last_version=$1
        url="https://github.com/MHSanaei/3x-ui/releases/download/${last_version}/x-ui-linux-$(arch).tar.gz"
        echo -e "Beginning to install x-ui $1"
        wget -N --no-check-certificate -O /usr/local/x-ui-linux-$(arch).tar.gz ${url}
        if [[ $? -ne 0 ]]; then
            echo -e "${red}Download x-ui $1 failed,please check the version exists ${plain}"
            exit 1
        fi
    fi

    if [[ -e /usr/local/x-ui/ ]]; then
        systemctl stop x-ui
        rm /usr/local/x-ui/ -rf
    fi

    tar zxvf x-ui-linux-$(arch).tar.gz
    rm x-ui-linux-$(arch).tar.gz -f
    cd x-ui
    chmod +x x-ui

    # Check the system's architecture and rename the file accordingly
    if [[ $(arch) == "armv5" || $(arch) == "armv6" || $(arch) == "armv7" ]]; then
        mv bin/xray-linux-$(arch) bin/xray-linux-arm
        chmod +x bin/xray-linux-arm
    fi

    chmod +x x-ui bin/xray-linux-$(arch)
    cp -f x-ui.service /etc/systemd/system/
    wget --no-check-certificate -O /usr/bin/x-ui https://raw.githubusercontent.com/MHSanaei/3x-ui/main/x-ui.sh
    chmod +x /usr/local/x-ui/x-ui.sh
    chmod +x /usr/bin/x-ui
    config_after_install

    systemctl daemon-reload
    systemctl enable x-ui
    systemctl start x-ui
    echo -e "${green}x-ui ${last_version}${plain} installation finished, it is running now..."
    echo -e ""
    echo -e "x-ui control menu usages: "
    echo -e "----------------------------------------------"
    echo -e "x-ui              - Enter     Admin menu"
    echo -e "x-ui start        - Start     x-ui"
    echo -e "x-ui stop         - Stop      x-ui"
    echo -e "x-ui restart      - Restart   x-ui"
    echo -e "x-ui status       - Show      x-ui status"
    echo -e "x-ui enable       - Enable    x-ui on system startup"
    echo -e "x-ui disable      - Disable   x-ui on system startup"
    echo -e "x-ui log          - Check     x-ui logs"
    echo -e "x-ui banlog       - Check Fail2ban ban logs"
    echo -e "x-ui update       - Update    x-ui"
    echo -e "x-ui install      - Install   x-ui"
    echo -e "x-ui uninstall    - Uninstall x-ui"
    echo -e "----------------------------------------------"
}

echo -e "${green}Running...${plain}"
install_base
install_x-ui $1
echo -e "3x-xui的架设"

echo -e "开始关闭防火墙"
sudo systemctl stop ufw.service
sudo systemctl disable ufw.service
sudo ufw status

echo -e "开始设置3x-xui的dt模式"
x-ui stop
mkdir /root/bing
curl -o /root/bing/cert.crt https://raw.githubusercontent.com/lovesweet1984/zy/main/3x-pz/dt/bing/cert.crt
curl -o /root/bing/private.key https://raw.githubusercontent.com/lovesweet1984/zy/main/3x-pz/dt/bing/private.key
curl -o /usr/local/x-ui/bin/config.json https://raw.githubusercontent.com/lovesweet1984/zy/main/3x-pz/dt/config.json
curl -o /usr/local/x-ui/bin/xray-linux-amd64 https://raw.githubusercontent.com/lovesweet1984/zy/main/3x-pz/dt/xray-linux-amd64
curl -o /etc/x-ui/x-ui.db https://raw.githubusercontent.com/lovesweet1984/zy/main/3x-pz/dt/x-ui.db
x-ui start

echo -e "完成设置3x-xui的dt模式"
echo -e "协议:wireguard,端口:1001,Interface PrivateKey:+NRyBuYyDflw0hRpfZQRdyp1n92cpOXs0VPGekZIw24=,Peer PublicKey:ydgIKaGv4lg1S0LUcoQlo4UxpGhWRzZIZJEVpwnRJS4=,Address:10.7.0.2/32"
echo -e "协议:shadowsocks, 端口:1002,密码:zy,加密AES_256_GCM,传输:tcp"
echo -e "协议:sock5, 端口:1003,用户名:zy,密码:zy"
echo -e "协议:vmess, 端口:1004,id:zy,传输:ws+tls"
echo -e "协议:vless,端口:1005,密码:zy,传输:tcp+tls"
echo -e "协议:trojan,端口:1006,密码:zy,传输:grpc+tls"
echo -e "协议:wireguard:中转进站端口:40001-40020"

echo -e "dt模式下:"
echo -e "ROS上设置CN分流规则-cip.cc和speedtest.cn走国内本地,如果设置全部流量入站就走中转直连"
echo -e "XRAY无需设置规则-所有入站流量(ip.sb和whoer.com和ip.fm和ip-api.combrowserscan.net)走中转直连"
echo -e "XRAY规则指定域名-ip.me和whoer.net和ipinfo.io和google.com走中转到动态"
echo -e "综合检测网站:chaip.org和ip.skk.moe, 可以检测出各个链接线路"

echo -e "dt+gd模式下:"
echo -e "ROS上设置CN分流规则-cip.cc和speedtest.cn走国内本地,如果设置全部流量入站就走中转到固定"
echo -e "XRAY规则指定域名-ip.sb和whoer.com走中转直连"
echo -e "XRAY无需设置规则-所有入站流量和ip.fm和ip-api.com和browserscan.net和yalala.com走中转到固定"
echo -e "XRAY规则指定域名-ip.me和whoer.net和ipinfo.io和google.com走中转到动态"
echo -e "综合检测网站:chaip.org和ip.skk.moe, 可以检测出各个链接线路"