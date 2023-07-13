# sing-box-yes

Convenient and quick installation and management sing-box:100:

sing-box is a new general agent platform, benchmarking *ray core and clash, and has many new [features](https://sing-box.sagernet.org/features/), currently supports the following protocols:

`inbound`:
- Shadowsocks (including shadowsocks2022)
- Vmess
-Trojan
-Naive
-Hysteria
- ShadowTLS
-Tun
-Redirect
-TProxy
-Socks
-HTTP

`outbound`:
- Shadowsocks (including shadowsocks2022)
- Vmess
-Trojan
-Wireguard
-Hysteria
- ShadowTLS
- ShadowsocksR
-VLESS
-Tor
-SSH
- DNS

For more content on sing-box, please click here: point_right: [official site](https://sing-box.sagernet.org/)
# A key installation  
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh)
```
After execution, the management menu will be displayed by itself, and the latest release version will be automatically installed through the menu option `1`. At the same time, you can also install the latest version through `sing-box install`

If you want to install a specific version (including Pre-release), please use the following command, replace `1.1-beta8` with a specific version number
```
bash <(curl -Ls https://raw.githubusercontent.com/FranzKafkaYu/sing-box-yes/master/install.sh) install 1.1-beta8
```
If you want to update to the latest release version after installation and keep the original configuration file, please use the following command or use the menu option `2` to update
```
sing-box update
```
If you want to update to a specific version (including Pre-release) after installation and keep the original configuration file, please use the following command to update, replace `1.1-beta8` with a specific version number
```
sing-box update 1.1-beta8
```
# A shortcut
Enter sing-box in the server command line and press Enter to enter the management menu. The current menu content is as follows:

```
   sing-box-v0.0.1 management script
   0. Exit script
———————————————
   1. Install sing-box service
   2. Update the sing-box service
   3. Uninstall the sing-box service
   4. Start the sing-box service
   5. Stop the sing-box service
   6. Restart the sing-box service
   7. Check the status of the sing-box
   8. Check the sing-box log
   9. Clear the sing-box log
   A. Check the sing-box configuration
———————————————
   B. Set the sing-box to start automatically
   C. Cancel the sing-box auto start
   D. Set the sing-box to clear the log regularly & restart
   E. Cancel the sing-box to clear the log regularly & reboot
———————————————
   F. One key to open bbr
   G. Apply for an SSL certificate with one click
 
[INF] Version information: sing-box 1.0.4.d2add33 (go1.19.1, linux/amd64, CGO disabled)
[INF] sing-box status: running
[INF] Whether the sing-box starts automatically at boot: Yes
[INF] #######################
[INF] Process ID: 303895
[INF] Run time: Sun 2022-09-18 14:52:42 CST; 1min 42s ago
[INF] Memory usage: 14336 kB
[INF] #######################
[INF] Configuration file path: /usr/local/etc/sing-box/config.json
[INF] Executable file path: /usr/local/bin/sing-box

```
If you are tired of typing numbers frequently, the script also provides some shortcut commands, as follows:
```
   sing-box - Show context menu (more features)
   sing-box start - start the sing-box service
   sing-box stop - stop the sing-box service
   sing-box restart - restart the sing-box service
   sing-box status - view the sing-box status
   sing-box enable - set the sing-box to start automatically at boot
   sing-box disable - disable the sing-box autostart
   sing-box log - view the sing-box log
   sing-box clear - clears the sing-box log
   sing-box update - update the sing-box service
   sing-box install - Install the sing-box service
   sing-box uninstall - Uninstall the sing-box service
```

# Instructions for use  
After installing sing-box, you may need to follow the following steps to use it normally:

1) Configure the server: The default path of the script is `/usr/local/etc/sing-box/config.json`, please use `nano` or `vim` to edit, the specific content can refer to the configuration sample section below , please fill in according to your actual situation
2) Configuration check: After editing and saving the configuration file, use the configuration file checking function provided by the script to check as much as possible. This function will check and confirm the format of the configuration. Please ensure that the check passes
3) Restart sing-box: After the configuration check is passed, you can use the restart function in the script to restart `sing-box` to observe whether `sing-box` works normally, please make sure it works normally
4) Download the client: Please download the client by yourself according to the operating environment, and decompress to obtain the executable file
5) Download geo data: `geoip.db`, `geosite.db` files are required for client operation, please manually download geo data and put them in the same directory as `sing-box` execution file
6) Configure the client: Please put `client_config.json` into the directory at the same level as the `sing-box` executable file, and modify it according to the configuration template and your actual situation.
7) Run the client:
Under Windows, please open the command line tool (PowerShell is recommended) as an administrator, and use the following command to run the client:
```
sing-box.exe run -c client_config.json
```
Under Linux, please run the client as root user:
```
sing-box run -c client_config.json
```

# Configuration example
- [shadowsocks2022](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/shadowsocks2022)
- [shadowsocks2022+shadowTLS](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/shadowsocks2022_with_shadowTLS)
- [trojan](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/trojan)
- [hysteria](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/hysteria)
- [vmess](https://github.com/FranzKafkaYu/sing-box-yes/tree/main/vmess)

When using, please modify the configuration of the server and client according to the template

# support system  
- Ubuntu
-Centos
- Debian
-Rocky
-Almalinux

# client

At present, sing-box is still under development, and the client support is not yet complete. Most of the time, you can use it by manually running the program. If you need some clients, you can try the following clients
- [V2rayN](https://github.com/2dust/v2rayN/releases/tag/5.36)
- [SingBox](https://github.com/daodao97/SingBox)

# Acknowledgments
[SagerNet/sing-box](https://github.com/SagerNet/sing-box)

# star:star2:

[![Stargazers over time](https://starchart.cc/FranzKafkaYu/sing-box-yes.svg)](https://starchart.cc/FranzKafkaYu/sing-box-yes)
