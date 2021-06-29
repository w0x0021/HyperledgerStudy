#1/usr/bin/env sh

##############################################################
# Copyleft(Ɔ) 2021 by w0x0021.
#
# Filename : onekey.sh
# Author   ：w0x0021
# Email    : w0x0021@gmail.com
# Site     : https://www.wangsansan.com
# Blog     : https://blog.csdn.net/byb123
# Date     : 2021-06-29 周二 09:57:36
#    
# Description ：
#     One key installation script of hyperledger fabric
##############################################################

AUTHOR="w0x0021"
TOOLS_PATH=/home/$USER/tools
GOLANG_PATH=/home/$USER/code/go

# Step.1
function init() {
    (check_system)
    mkdir -p $GOLANG_PATH
    mkdir -p $TOOLS_PATH/golang
    mkdir -p $TOOLS_PATH/docker-compose
}

# Step.2
function install_CommonTools() {
    echo "[+] Install Common Tools: git/curl"
    echo "    [*] apt update..."
    sudo apt-get update 
    echo "    [*] Install git..."
    sudo apt-get install -y git > /dev/null
    echo "    [*] Install curl..."
    sudo apt-get install -y curl > /dev/null
    echo "[-] Install Common Tools Finish."
}

# Step.3
function install_Golang() {
    echo "[+] Install Golang"
    echo "    [*] Install golang-1.16..."
    wget https://studygolang.com/dl/golang/go1.16.5.linux-amd64.tar.gz -O $TOOLS_PATH/golang/go1.16.5.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf $TOOLS_PATH/golang/go1.16.5.linux-amd64.tar.gz

    if [ 0"$GOPATH" = "0" ];then        # 该方式判断只防止第二次打开bash重新写入，同bash下二次操作并未刷新$GOPATH，需要修复
        sudo chmod 666 /etc/profile
        sudo echo "" >> /etc/profile
        sudo echo "export GOPATH=/home/fabric/code/go" >> /etc/profile
        sudo echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" >> /etc/profile
        sudo echo "export GO111MODULE=auto" >> /etc/profile
        sudo chmod 644 /etc/profile
    fi
    source /etc/profile
    
    echo "    [*] Golang Build Test..."
    go_test_path=$GOLANG_PATH/src/$AUTHOR/go_test
    go_test_source=$go_test_path/main.go
    mkdir -p $go_test_path
    echo ""                                     >  $go_test_source
    echo "package main"                         >> $go_test_source
    echo ""                                     >> $go_test_source
    echo "import (\"fmt\")"                     >> $go_test_source
    echo ""                                     >> $go_test_source
    echo "func main() {"                        >> $go_test_source
    echo "    fmt.Printf(\"Hello world\n\")"    >> $go_test_source
    echo "}"                                    >> $go_test_source
    go install $go_test_path
    echo "    [-] Golang Build Test Finish."
    echo "[-] Install Golang Finish."
}

# Step.4
function install_Docker() {
    echo "[+] Install Docker"
    sudo curl -sSl https://get.docker.com | sh
    sudo usermod -aG docker $USER

    if [ ! -f "/etc/default/docker.back" ]; then
        sudo cp /etc/default/docker /etc/default/docker.back
    fi

    sudo cp /etc/default/docker.back /etc/default/docker
    sudo chmod 666 /etc/default/docker
    sudo echo "" >> /etc/default/docker
    sudo echo "DOCKER_OPTS=\"-s=aufs -r=true ——api-cors-header='*' -H tcp：//0.0.0.0：2375 -H unix：///var/run/docker.sock \"" >> /etc/default/docker
    sudo chmod 644 /etc/default/docker
    sudo service docker start
    echo "[-] Install Docker Finish."
}

# Step.5
function install_DockerCompose() {
    echo "[+] Install Docker Compose"
    sudo wget https://github.com/docker/compose/releases/download/1.29.2/docker-compose-Linux-x86_64 -O /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo "[-] Install Docker Compose Finish."
}

# Step.6
function download_HyperledgerFabric() {
    echo "[+] Download Hyperledger Fabric"
    go get github.com/hyperledger/fabric
    echo "[-] Download Hyperledger Fabric Finish."
}

##############################
# Other function
##############################
function get_distribution() {
	lsb_dist=""
	
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	
	echo "$lsb_dist"
}

function check_system() {
    lsb_dist=$( get_distribution )
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"
    case "$lsb_dist" in
		ubuntu|debian|raspbian)     # 此脚本适用的白名单操作系统
        ;;
        *)
            echo "The current operating system is not \"Ubuntu\""
            exit
        ;;
    esac
}

case $1 in 
*)
    init
    install_CommonTools
    install_Golang
    install_Docker
    install_DockerCompose
    download_HyperledgerFabric
    ;;
esac
