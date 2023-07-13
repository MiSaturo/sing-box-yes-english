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
         LOGE"could not find sing-box packages, plz check dowanload sing-box whether suceess"
         exit 1
     the fi
     cd ${DOWNLAOD_PATH}
     #decompress sing-box packages
     tar -xvf sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}.tar.gz && cd sing-box-${SING_BOX_VERSION}-linux-${OS_ARCH}

     if [[ $? -ne 0 ]]; then
         clear_sing_box
         LOGE "Failed to decompress the sing-box installation package, the script exited"
         exit 1
     else
         LOGI "Decompressed the sing-box installation package successfully"
     the fi

     #install sing-box
     install -m 755 sing-box ${BINARY_FILE_PATH}

     if [[ $? -ne 0 ]]; then
         LOGE "install sing-box failed, exit"
         exit 1
     else
         LOGI "install sing-box suceess"
     the fi
     install_systemd_service && enable_sing-box && start_sing-box
     LOGI "sing-box installed successfully, started successfully"
}

#update sing-box
update_sing-box() {
     LOGD "Starting to update sing-box..."
     if [[ ! -f "${SERVICE_FILE_PATH}" ]]; then
         LOGE "Sing-box is not installed in the current system, please use the update command on the premise of installing sing-box"
         show_menu
     the fi
     #here we need back up config first, and then restore it after installation
     backup_config
     #get the version paremeter
     if [[ $# -ne 0 ]]; then
         install_sing-box $1
     else
         install_sing-box
     the fi
     restore_config
     if ! systemctl restart sing-box; then
         LOGE "update sing-box failed, please check logs"
         show_menu
     else
         LOGI "update sing-box success"
     the fi
}

clear_sing_box() {
     LOGD "Starting clearing sing-box..."
     create_or_delete_path 0 && rm -rf ${SERVICE_FILE_PATH} && rm -rf ${BINARY_FILE_PATH} && rm -rf ${SCRIPT_FILE_PATH}
     LOGD "Completed clearing sing-box"
}

#uninstall sing-box
uninstall_sing-box() {
     LOGD "Beginning to uninstall sing-box..."
     pidOfsing_box=$(pidof sing-box)
     if [ -n ${pidOfsing_box} ]; then
         stop_sing-box
     the fi
     clear_sing_box

     if [ $? -ne 0 ]; then
         LOGE "Failed to uninstall sing-box, please check the log"
         exit 1
     else
         LOGI "Uninstall sing-box successfully"
     the fi
}

#install systemd service
install_systemd_service() {
     LOGD "Starting installation of sing-box systemd service..."
     if [ -f "${SERVICE_FILE_PATH}" ]; then
         rm -rf ${SERVICE_FILE_PATH}
     the fi
     #create service file
     touch ${SERVICE_FILE_PATH}
     if [ $? -ne 0 ]; then
         LOGE "create service file failed, exit"
         exit 1
     else
         LOGI "create service file success..."
     the fi
     cat >${SERVICE_FILE_PATH} <<EOF
[Unit]
Description=sing-box Service
Documentation=https://sing-box.sagernet.org/
After=network.target nss-lookup.target
Wants=network.target
[Service]
Type=simple
ExecStart=${BINARY_FILE_PATH} run -c ${CONFIG_FILE_PATH}/config.json
Restart=on-failure
RestartSec=30s
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
     chmod 644 ${SERVICE_FILE_PATH}
     systemctl daemon-reload
     LOGD "Sing-box systemd service installed successfully"
}

#start sing-box
start_sing-box() {
     if [ -f "${SERVICE_FILE_PATH}" ]; then
         systemctl start sing-box
         sleep 1s
         status_check
         if [ $? == ${SING_BOX_STATUS_NOT_RUNNING} ]; then
             LOGE "start sing-box service failed, exit"
             exit 1
         elif [ $? == ${SING_BOX_STATUS_RUNNING} ]; then
             LOGI "start sing-box service success"
         the fi
     else
         LOGE "${SERVICE_FILE_PATH} does not exist, can not start service"
         exit 1
     the fi
}

#restart sing-box
restart_sing-box() {
     if [ -f "${SERVICE_FILE_PATH}" ]; then
         systemctl restart sing-box
         sleep 1s
         status_check
         if [ $? == 0 ]; then
             LOGE "restart sing-box service failed, exit"
             exit 1
         elif [ $? == 1 ]; then
             LOGI "restart sing-box service success"
         the fi
     else
         LOGE "${SERVICE_FILE_PATH} does not exist, can not restart service"
         exit 1
     the fi
}

#stop sing-box
stop_sing-box() {
     LOGD "Starting to stop the sing-box service..."
     status_check
     if [ $? == ${SING_BOX_STATUS_NOT_INSTALL} ]; then
         LOGE "sing-box did not install, can not stop it"
         exit 1
     elif [ $? == ${SING_BOX_STATUS_NOT_RUNNING} ]; then
         LOGI "sing-box already stopped, no need to stop it again"
         exit 1
     elif [ $? == ${SING_BOX_STATUS_RUNNING} ]; then
         if ! systemctl stop sing-box; then
             LOGE "stop sing-box service failed, plz check logs"
             exit 1
         the fi
     the fi
     LOGD "Successfully stopped the sing-box service"
}

#enable sing-box will set sing-box auto start on system boot
enable_sing-box() {
     systemctl enable sing-box
     if [[ $? == 0 ]]; then
         LOGI "Succeeded in setting the sing-box to boot automatically"
     else
         LOGE "Failed to configure sing-box to start automatically"
     the fi
}

#disable sing-box
disable_sing-box() {
     systemctl disable sing-box
     if [[ $? == 0 ]]; then
         LOGI "Cancel sing-box autostart successfully"
     else
         LOGE "Failed to cancel sing-box autostart"
     the fi
}

#show logs
show_log() {
     status_check
     if [[ $? == ${SING_BOX_STATUS_NOT_RUNNING} ]]; then
         journalctl -u sing-box.service -e --no-pager -f
     else
         confirm "Confirm whether logging is enabled in the configuration, it is enabled by default" "y"
         if [[ $? -ne 0 ]]; then
             LOGI "will read logs from console:"
             journalctl -u sing-box.service -e --no-pager -f
         else
             local tempLog=''
             read -p "The log will be read from the log file, please enter the path of the log file, press Enter to use the default path": tempLog
             if [[ -n ${tempLog} ]]; then
                 LOGI "Log file path: ${tempLog}"
                 if [[ -f ${tempLog} ]]; then
                     tail -f ${tempLog} -s 3
                 else
                     LOGE "${tempLog} does not exist, please confirm the configuration"
                 the fi
             else
                 LOGI "Log file path: ${DEFAULT_LOG_FILE_SAVE_PATH}"
                 tail -f ${DEFAULT_LOG_FILE_SAVE_PATH} -s 3
             the fi
         the fi
     the fi
}

#clear log, the paremter is log file path
clear_log() {
     local filePath=''
     if [[ $# -gt 0 ]]; then
         filePath=$1
     else
         read -p "Please enter the log file path": filePath
         if [[ ! -n ${filePath} ]]; then
             LOGI "The log file path entered is invalid, the default file path will be used"
             filePath=${DEFAULT_LOG_FILE_SAVE_PATH}
         the fi
     the fi
     LOGI "The log path is: ${filePath}"
     if [[ ! -f ${filePath} ]]; then
         LOGE "Failed to clear the sing-box log file, ${filePath} does not exist, please confirm"
         exit 1
     the fi
     fileSize=$(ls -la ${filePath} --block-size=M | awk '{print $5}' | awk -F 'M' '{print $1}')
     if [[ ${fileSize} -gt ${DEFAULT_LOG_FILE_DELETE_TRIGGER} ]]; then
         rm $1 && systemctl restart sing-box
         if [[ $? -ne 0 ]]; then
             LOGE "Failed to clear sing-box log file"
         else
             LOGI "Cleared sing-box log file successfully"
         the fi
     else
         LOGI "The current log size is ${fileSize}M, which is smaller than ${DEFAULT_LOG_FILE_DELETE_TRIGGER}M, and will not be cleared"
     the fi
}

#enable auto delete log, need file path as
enable_auto_clear_log() {
     LOGI "Set sing-box to clear log regularly..."
     local disabled=false
     disabled=$(cat ${CONFIG_FILE_PATH}/config.json | jq .log.disabled | tr -d '"')
     if [[ ${disabled} == "true" ]]; then
         LOGE "The current system does not open the log, will directly exit the script"
         exit 0
     the fi
     local filePath=''
     if [[ $# -gt 0 ]]; then
         filePath=$1
     else
         filePath=$(cat ${CONFIG_FILE_PATH}/config.json | jq .log.output | tr -d '"')
     the fi
     if [[ ! -f ${filePath} ]]; then
         LOGE "${filePath} does not exist, setting sing-box to clear logs regularly failed"
         exit 1
     the fi
     crontab -l >/tmp/crontabTask.tmp
     echo "0 0 * * 6 sing-box clear ${filePath}" >>/tmp/crontabTask.tmp
     crontab /tmp/crontabTask.tmp
     rm /tmp/crontabTask.tmp
     LOGI "Set sing-box to clear log ${filePath} successfully"
}

#disable auto delete log
disable_auto_clear_log() {
     crontab -l | grep -v "sing-box clear" | crontab -
     if [[ $? -ne 0 ]]; then
         LOGI "Failed to cancel sing-box timing clear log"
     else
         LOGI "Succeeded in canceling the sing-box timing clear log"
     the fi
}

#enable bbr
enable_bbr() {
     # temporary workaround for installing bbr
     bash <(curl -L -s https://raw.githubusercontent.com/teddysun/across/master/bbr.sh)
     echo ""
}

#for cert issue
ssl_cert_issue() {
     bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/BashScripts/main/SSLAutoInstall/SSLAutoInstall.sh)
}

#show help
show_help() {
     echo "sing-box-v${SING_BOX_YES_VERSION} management script usage: "
     echo "------------------------------------------"
     echo "sing-box - show shortcut menu (more functions)"
     echo "sing-box start - start the sing-box service"
     echo "sing-box stop - stop the sing-box service"
     echo "sing-box restart - restart the sing-box service"
     echo "sing-box status - check the sing-box status"
     echo "sing-box enable - set the sing-box to start automatically"
     echo "sing-box disable - disable sing-box from booting"
     echo "sing-box log - view the sing-box log"
     echo "sing-box clear - clear the sing-box log"
     echo "sing-box update - update the sing-box service"
     echo "sing-box install - install sing-box service"
     echo "sing-box uninstall - uninstall the sing-box service"
     echo "------------------------------------------"
}

#show menu
show_menu() {
     echo -e "
   ${green}sing-box-v${SING_BOX_YES_VERSION} management script ${plain}
   ${green}0.${plain} exit script
———————————————
   ${green}1.${plain} install sing-box service
   ${green}2.${plain} update sing-box service
   ${green}3.${plain} Uninstall sing-box service
   ${green}4.${plain} start sing-box service
   ${green}5.${plain} stop sing-box service
   ${green}6.${plain} Restart the sing-box service
   ${green}7.${plain} View sing-box status
   ${green}8.${plain} View sing-box log
   ${green}9.${plain} clears the sing-box log
   ${green}A.${plain} checks the sing-box configuration
———————————————
   ${green}B.${plain} set sing-box to start automatically
   ${green}C.${plain} cancel sing-box autostart
   ${green}D.${plain} set sing-box clear log & restart
   ${green}E.${plain} cancel sing-box clear log & restart
———————————————
   ${green}F.${plain} one-click open bbr
   ${green}G.${plain} One-click application for SSL certificate
  "
     show_status
     echo && read -p "Please enter the selection [0-G]:" num

     case "${num}" in
     0)
         exit 0
         ;;
     1)
         install_sing-box && show_menu
         ;;
     2)
         update_sing-box && show_menu
         ;;
     3)
         uninstall_sing-box && show_menu
         ;;
     4)
         start_sing-box && show_menu
         ;;
     5)
         stop_sing-box && show_menu
         ;;
     6)
         restart_sing-box && show_menu
         ;;
     7)
         show_menu
         ;;
     8)
         show_log && show_menu
         ;;
     9)
         clear_log && show_menu
         ;;
     A)
         config_check && show_menu
         ;;
     B)
         enable_sing-box&& show_menu
         ;;
     c)
         disable_sing-box && show_menu
         ;;
     d)
         enable_auto_clear_log
         ;;
     E)
         disable_auto_clear_log
         ;;
     f)
         enable_bbr && show_menu
         ;;
     G)
         ssl_cert_issue
         ;;
     *)
         LOGE "Please enter the correct option [0-G]"
         ;;
     esac
}

start_to_run() {
     set_as_entrance
     clear
     show_menu
}

main() {
     if [[ $# > 0 ]]; then
         case $1 in
         "start")
             start_sing-box
             ;;
         "stop")
             stop_sing-box
             ;;
         "restart")
             restart_sing-box
             ;;
         "status")
             show_status
             ;;
         "enable")
             enable_sing-box
             ;;
         "disable")
             disable_sing-box
             ;;
         "log")
             show_log
             ;;
         "clear")
             clear_log
             ;;
         "update")
             if [[ $# == 2 ]]; then
                 update_sing-box $2
             else
                 update_sing-box
             the fi
             ;;
         "install")
             if [[ $# == 2 ]]; then
                 install_sing-box $2
             else
                 install_sing-box
             the fi
             ;;
         "uninstall")
             uninstall_sing-box
             ;;
         *) show_help;;
         esac
     else
         start_to_run
     the fi
}

main $*
