#!/bin/bash

#################################################### ###
#This shell script is used for sing-box installation
#Usage:
#
#Author: FranzKafka
#Date: 2022-09-15
#Version:0.0.1
#################################################### ###

#Some basic definitions
plain='\033[0m'
red='\033[0;31m'
blue='\033[1;34m'
pink='\033[1;35m'
green='\033[0;32m'
yellow='\033[0;33m'

#os
OS_RELEASE=''

#arch
OS_ARCH=''

#sing-box version
SING_BOX_VERSION=''

#script version
SING_BOX_YES_VERSION='0.0.2'

#package download path
DOWNLAOD_PATH='/usr/local/sing-box'

#backup config path
CONFIG_BACKUP_PATH='/usr/local/etc'

#config install path
CONFIG_FILE_PATH='/usr/local/etc/sing-box'

#binary install path
BINARY_FILE_PATH='/usr/local/bin/sing-box'

#scritp install path
SCRIPT_FILE_PATH='/usr/local/sbin/sing-box'

#service install path
SERVICE_FILE_PATH='/etc/systemd/system/sing-box.service'

#log file save path
DEFAULT_LOG_FILE_SAVE_PATH='/usr/local/sing-box/sing-box.log'

#sing-box status define
declare -r SING_BOX_STATUS_RUNNING=1
declare -r SING_BOX_STATUS_NOT_RUNNING=0
declare -r SING_BOX_STATUS_NOT_INSTALL=255

#log file size which will trigger log clear
#here we set it as 25M
declare -r DEFAULT_LOG_FILE_DELETE_TRIGGER=25

#utils
function LOGE() {
     echo -e "${red}[ERR] $* ${plain}"
}

function LOGI() {
     echo -e "${green}[INF] $* ${plain}"
}

function LOGD() {
     echo -e "${yellow}[DEG] $* ${plain}"
}

confirm() {
     if [[ $# > 1 ]]; then
         echo && read -p "$1 [default $2]: " temp
         if [[ x"${temp}" == x"" ]]; then
             temp=$2
         the fi
     else
         read -p "$1 [y/n]: " temp
     the fi
     if [[ x"${temp}" == x"y" || x"${temp}" == x"Y" ]]; then
         return 0
     else
         return 1
     the fi
}

#Rootcheck
[[ $EUID -ne 0 ]] && LOGE "Please use root user to run this script" && exit 1

#System check
os_check() {
     LOGI "Detecting current system..."
     if [[ -f /etc/redhat-release ]]; then
         OS_RELEASE="centos"
     elif cat /etc/issue | grep -Eqi "debian"; then
         OS_RELEASE="debian"
     elif cat /etc/issue | grep -Eqi "ubuntu"; then
         OS_RELEASE="ubuntu"
     elif cat /etc/issue | grep -Eqi "centos|red hat|redhat"; then
         OS_RELEASE="centos"
     elif cat /proc/version | grep -Eqi "debian"; then
         OS_RELEASE="debian"
     elif cat /proc/version | grep -Eqi "ubuntu"; then
         OS_RELEASE="ubuntu"
     elif cat /proc/version | grep -Eqi "centos|red hat|redhat"; then
         OS_RELEASE="centos"
     else
         LOGE "System detection error, please contact the script author!" && exit 1
     the fi
     LOGI "The system detection is complete, the current system is: ${OS_RELEASE}"
}

#arch check
arch_check() {
     LOGI "Detecting current system architecture..."
     OS_ARCH=$(arch)
     LOGI "Current system architecture is ${OS_ARCH}"

     if [[ ${OS_ARCH} == "x86_64" || ${OS_ARCH} == "x64" || ${OS_ARCH} == "amd64" ]]; then
         OS_ARCH="amd64"
     elif [[ ${OS_ARCH} == "aarch64" || ${OS_ARCH} == "arm64" ]]; then
         OS_ARCH="arm64"
     else
         OS_ARCH="amd64"
         LOGE "Failed to detect system architecture, using default architecture: ${OS_ARCH}"
     the fi
     LOGI "The system architecture detection is complete, the current system architecture is: ${OS_ARCH}"
}

#sing-box status check, -1 means didn't install, 0 means failed, 1 means running
status_check() {
     if [[ ! -f "${SERVICE_FILE_PATH}" ]]; then
         return ${SING_BOX_STATUS_NOT_INSTALL}
     the fi
     temp=$(systemctl status sing-box | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
     if [[ x"${temp}" == x"running" ]]; then
         return ${SING_BOX_STATUS_RUNNING}
     else
         return ${SING_BOX_STATUS_NOT_RUNNING}
     the fi
}

#check config provided by sing-box core
config_check() {
     if [[ ! -f "${CONFIG_FILE_PATH}/config.json" ]]; then
         LOGE "${CONFIG_FILE_PATH}/config.json does not exist, configuration check failed"
         return
     else
         info=$(${BINARY_FILE_PATH} check -c ${CONFIG_FILE_PATH}/config.json)
         if [[ $? -ne 0 ]]; then
             LOGE "Configuration check failed, please check the log"
         else
             LOGI "Congratulations: configuration check passed"
         the fi
     the fi
}

set_as_entrance() {
     if [[ ! -f "${SCRIPT_FILE_PATH}" ]]; then
         wget --no-check-certificate -O ${SCRIPT_FILE_PATH} https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/main/install.sh
         chmod +x ${SCRIPT_FILE_PATH}
     the fi
}

#show sing-box status
show_status() {
     status_check
     case $? in
     0)
         show_sing_box_version
         echo -e "[INF] sing-box status: ${yellow} not running ${plain}"
         show_enable_status
         LOGI "Configuration file path: ${CONFIG_FILE_PATH}/config.json"
         LOGI "Executable file path: ${BINARY_FILE_PATH}"
         ;;
     1)
         show_sing_box_version
         echo -e "[INF] sing-box status: ${green} is running ${plain}"
         show_enable_status
         show_running_status
         LOGI "Configuration file path: ${CONFIG_FILE_PATH}/config.json"
         LOGI "Executable file path: ${BINARY_FILE_PATH}"
         ;;
     255)
         echo -e "[INF] sing-box status: ${red} is not installed ${plain}"
         ;;
     esac
}

#show sing-box running status
show_running_status() {
     status_check
     if [[ $? == ${SING_BOX_STATUS_RUNNING} ]]; then
         local pid=$(pidof sing-box)
         local runTime=$(systemctl status sing-box | grep Active | awk '{for (i=5;i<=NF;i++)printf("%s ", $i);print ""}')
         local memCheck=$(cat /proc/${pid}/status | grep -i vmrss | awk '{print $2,$3}')
         LOGI "#######################"
         LOGI "Process ID: ${pid}"
         LOGI "Runtime: ${runTime}"
         LOGI "Memory usage: ${memCheck}"
         LOGI "#######################"
     else
         LOGE "sing-box is not running"
     the fi
}

#show sing-box version
show_sing_box_version() {
     LOGI "Version information: $(${BINARY_FILE_PATH} version)"
}

#show sing-box enable status,enabled means sing-box can auto start when system boot on
show_enable_status() {
     local temp=$(systemctl is-enabled sing-box)
     if [[ x"${temp}" == x"enabled" ]]; then
         echo -e "[INF] Whether the sing-box starts automatically: ${green} is ${plain}"
     else
         echo -e "[INF] Whether the sing-box starts automatically: ${red}No ${plain}"
     the fi
}

#installation path create & delete,1->create,0->delete
create_or_delete_path() {

     if [[ $# -ne 1 ]]; then
         LOGE "invalid input, should be one paremete, and can be 0 or 1"
         exit 1
     the fi
     if [[ "$1" == "1" ]]; then
         LOGI "Will create ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} for sing-box..."
         rm -rf ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
         mkdir -p ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
         if [[ $? -ne 0 ]]; then
             LOGE "create ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} for sing-box failed"
             exit 1
         else
             LOGI "create ${DOWNLAOD_PATH} adn ${CONFIG_FILE_PATH} for sing-box success"
         the fi
     elif [[ "$1" == "0" ]]; then
         LOGI "Will delete ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH}..."
         rm -rf ${DOWNLAOD_PATH} ${CONFIG_FILE_PATH}
         if [[ $? -ne 0 ]]; then
             LOGE "delete ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} failed"
             exit 1
         else
             LOGI "delete ${DOWNLAOD_PATH} and ${CONFIG_FILE_PATH} success"
         the fi
     the fi

}

#install some common utils
install_base() {
     if [[ ${OS_RELEASE} == "ubuntu" || ${OS_RELEASE} == "debian" ]]; then
         apt install wget tar jq -y
     elif [[ ${OS_RELEASE} == "centos" ]]; then
         yum install wget tar jq -y
     the fi
}

#download sing-box binary
download_sing-box() {
     LOGD "Starting downloading sing-box..."
     os_check && arch_check && install_base
     if [[ $# -gt 1 ]]; then
         echo -e "${red}invalid input, plz check your input: $* ${plain}"
         exit 1
     elif [[ $# -eq 1 ]]; then
         SING_BOX_VERSION=$1
         local SING_BOX_VERSION_TEMP="v${SING_BOX_VERSION}"
     else
         local SING_BOX_VERSION_TEMP=$(curl -Ls "https://api.github.com/repos/SagerNet/sing-box/releases/latest" | grep '"tag_name":' | sed -E 's/.*"( [^"]+)".*/\1/')
         SING_BOX_VERSION=${SING_BOX_VERSION_TEMP:1}
     the fi
     LOGI "Will choose to use version: ${SING_BOX_VERSION}"
     local DOWANLOAD_URL="https://github.com/SagerNet/sing-box/releases/download/${SING_BOX_VERSION_TEMP}/sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz"

     #here we need create directory for sing-box
     create_or_delete_path 1
     wget -N --no-check-certificate -O ${DOWNLAOD_PATH}/sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz ${DOWANLOAD_URL}

     if [[ $? -ne 0 ]]; then
         LOGE "Download sing-box failed, plz be sure that your network work properly and can access github"
         create_or_delete_path 0
         exit 1
     else
         LOGI "Downloaded sing-box successfully"
     the fi
}

#dwonload config examples, this should be called when dowanload sing-box
download_config() {
     LOGD "Starting to download sing-box configuration template..."
     if [[ ! -d ${CONFIG_FILE_PATH} ]]; then
         mkdir -p ${CONFIG_FILE_PATH}
     the fi
     if [[ ! -f "${CONFIG_FILE_PATH}/config.json" ]]; then
         wget --no-check-certificate -O ${CONFIG_FILE_PATH}/config.json https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/main/shadowsocks2022/server_config.json
         if [[ $? -ne 0 ]]; then
             LOGE "Failed to download the sing-box configuration template, please check the network"
             exit 1
         else
             LOGI "Successfully downloaded the sing-box configuration template"
         the fi
     else
         LOGI "${CONFIG_FILE_PATH} already exists, no need to download again"
     the fi
}

#backup config, this will be called when update sing-box
backup_config() {
     LOGD "Starting backup of sing-box configuration file..."
     if [[ ! -f "${CONFIG_FILE_PATH}/config.json" ]]; then
         LOGE "There are currently no configuration files to back up"
         return 0
     else
         mv ${CONFIG_FILE_PATH}/config.json ${CONFIG_BACKUP_PATH}/config.json.bak
     the fi
     LOGD "Backup sing-box configuration file complete"
}

#backup config, this will be called when update sing-box
restore_config() {
     LOGD "Starting to restore sing-box configuration files..."
     if [[ ! -f "${CONFIG_BACKUP_PATH}/config.json.bak" ]]; then
         LOGE "There are currently no configuration files to back up"
         return 0
     else
         mv ${CONFIG_BACKUP_PATH}/config.json.bak ${CONFIG_FILE_PATH}/config.json
     the fi
     LOGD "Restore sing-box configuration file completed"
}

#install sing-box, in this function we will download binary, paremete $1 will be used as version if it's given
install_sing-box() {
     set_as_entrance
     LOGD "Starting to install sing-box..."
     if [[ $# -ne 0 ]]; then
         download_sing-box $1
     else
         download_sing-box
     the fi
     download_config
     if [[ ! -f "${DOWNLAOD_PATH}/sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz" ]]; then
         clear_sing_box
         LOGE
