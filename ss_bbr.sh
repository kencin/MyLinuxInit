#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#=================================================
#       System Required: CentOS 6+/Debian 6+/Ubuntu 14.04+
#       Description: Install the ShadowsocksR mudbjson server
#       Author: Kencin
#       PreAuthor: Toyo
#=================================================

sh_ver="1.0.26"
filepath=$(cd "$(dirname "$0")"; pwd)
file=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
ssr_folder="/usr/local/shadowsocksr"
config_file="${ssr_folder}/config.json"
config_user_file="${ssr_folder}/user-config.json"
config_user_api_file="${ssr_folder}/userapiconfig.py"
config_user_mudb_file="${ssr_folder}/mudb.json"
ssr_log_file="${ssr_folder}/ssserver.log"
Libsodiumr_file="/usr/local/lib/libsodium.so"
Libsodiumr_ver_backup="1.0.15"
erver_Speeder_file="/serverspeeder/bin/serverSpeeder.sh"
LotServer_file="/appex/bin/serverSpeeder.sh"
BBR_file="${file}/bbr.sh"
jq_file="${ssr_folder}/jq"

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"
Separator_1="——————————————————————————————"
python3_ver="python3"
getNodeId="/usr/local/shadowsocksr/getNodeId.py"
pip3="/usr/local/bin/pip3"
manyuse_link="https://github.com/kencin/MyLinuxInit/raw/master/shadowsocks/shadowsocksr-manyuser.zip"
manyuse_file_name="shadowsocksr-manyuser.zip"
manyuse_folder_name="shadowsocksr-manyuser"
ssrmu_centos_link="https://raw.githubusercontent.com/kencin/MyLinuxInit/master/shadowsocks/ssrmu_centos"
ssrmu_debian_link="https://raw.githubusercontent.com/kencin/MyLinuxInit/master/shadowsocks/ssrmu_debian"

check_root(){
        [[ $EUID != 0 ]] && echo -e "${Error} 当前账号非ROOT(或没有ROOT权限)，无filepath=$(cd "$(dirname "$0")"; pwd)
file=$(echo -e "${filepath}"|awk -F "$0" '{print $1}')
法继续操作，请使用${Green_background_prefix} sudo su ${Font_color_suffix}来获取>临时ROOT权限（执行后会提示输入当前账号的密码）。" && exit 1
}

Check_python(){
        python_ver=`python -h`
        if [[ -z ${python_ver} ]]; then
                echo -e "${Info} 没有安装Python，开始安装..."
                if [[ ${release} == "centos" ]]; then
                        yum install -y python
                else
                        apt-get install -y python
                fi
        fi
}

Check_python3(){
        python_ver=`python3 -h`
        if [[ -z ${python_ver} ]]; then
                echo -e "${Info} 没有安装Python，开始安装..."
                if [[ ${release} == "centos" ]]; then
                        yum install -y python3
                else
                        apt-get install -y python3
                fi
        fi
}

# 下载 ShadowsocksR
Download_SSR(){
        cd "/usr/local"
        wget -N --no-check-certificate ${manyuse_link}
        #git config --global http.sslVerify false
        #env GIT_SSL_NO_VERIFY=true git clone -b manyuser https://github.com/ToyoDAdoubiBackup/shadowsocksr.git
        #[[ ! -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR服务端 下载失败 !" && exit 1
        [[ ! -e ${manyuse_file_name} ]] && echo -e "${Error} ShadowsocksR服务端 压缩包 下载失败 !" && rm -rf ${manyuse_file_name} && exit 1
        unzip ${manyuse_file_name}
        [[ ! -e "/usr/local/${manyuse_folder_name}/" ]] && echo -e "${Error} ShadowsocksR服务端 解压失败 !" && rm -rf ${manyuse_file_name} && exit 1
        mv "/usr/local/${manyuse_folder_name}/" "/usr/local/shadowsocksr/"
        [[ ! -e "/usr/local/shadowsocksr/" ]] && echo -e "${Error} ShadowsocksR服务端 重命名失败 !" && rm -rf ${manyuse_file_name} && rm -rf "/usr/local/${manyuse_folder_name}/" && exit 1
        rm -rf ${manyuse_file_name}
        cd "shadowsocksr"
        cp "${ssr_folder}/config.json" "${config_user_file}"
        cp "${ssr_folder}/mysql.json" "${ssr_folder}/usermysql.json"
        cp "${ssr_folder}/apiconfig.py" "${config_user_api_file}"
        [[ ! -e ${config_user_api_file} ]] && echo -e "${Error} ShadowsocksR服务端 apiconfig.py 复制失败 !" && exit 1
        echo -e "${Info} ShadowsocksR服务端 下载完成 !"
}

Service_SSR(){
        if [[ ${release} = "centos" ]]; then
                if ! wget --no-check-certificate ${ssrmu_centos_link} -O /etc/init.d/ssrmu; then
                        echo -e "${Error} ShadowsocksR服务 管理脚本下载失败 !" && exit 1
                fi
                chmod +x /etc/init.d/ssrmu
                chkconfig --add ssrmu
                chkconfig ssrmu on
        else
                if ! wget --no-check-certificate ${ssrmu_debian_link} -O /etc/init.d/ssrmu; then
                        echo -e "${Error} ShadowsocksR服务 管理脚本下载失败 !" && exit 1
                fi
                chmod +x /etc/init.d/ssrmu
                update-rc.d -f ssrmu defaults
        fi
        echo -e "${Info} ShadowsocksR服务 管理脚本下载完成 !"
}


Centos_yum(){
        yum update
        cat /etc/redhat-release |grep 7\..*|grep -i centos>/dev/null
        if [[ $? = 0 ]]; then
                yum install -y vim unzip crond net-tools
        else
                yum install -y vim unzip crond
        fi
}
Debian_apt(){
        apt-get update
        cat /etc/issue |grep 9\..*>/dev/null
        if [[ $? = 0 ]]; then
                apt-get install -y vim unzip cron net-tools
        else
                apt-get install -y vim unzip cron
        fi
}

check_sys(){
        if [[ -f /etc/redhat-release ]]; then
                release="centos"
        elif cat /etc/issue | grep -q -E -i "debian"; then
                release="debian"
        elif cat /etc/issue | grep -q -E -i "ubuntu"; then
                release="ubuntu"
        elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
                release="centos"
        elif cat /proc/version | grep -q -E -i "debian"; then
                release="debian"
        elif cat /proc/version | grep -q -E -i "ubuntu"; then
                release="ubuntu"
        elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
                release="centos"
    fi
        bit=`uname -m`
}

# 安装 JQ解析器
JQ_install(){
        if [[ ! -e ${jq_file} ]]; then
                cd "${ssr_folder}"
                if [[ ${bit} = "x86_64" ]]; then
                        mv "jq-linux64" "jq"
                        #wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64" -O ${jq_file}
                else
                        mv "jq-linux32" "jq"
                        #wget --no-check-certificate "https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32" -O ${jq_file}
                fi
                [[ ! -e ${jq_file} ]] && echo -e "${Error} JQ解析器 重命名失败，请检查 !" && exit 1
                chmod +x ${jq_file}
                echo -e "${Info} JQ解析器 安装完成，继续..."
        else
                echo -e "${Info} JQ解析器 已安装，继续..."
        fi
}
# 安装 依赖
Installation_dependency(){
        if [[ ${release} == "centos" ]]; then
                Centos_yum
        else
                Debian_apt
        fi
        [[ ! -e "/usr/bin/unzip" ]] && echo -e "${Error} 依赖 unzip(解压压缩包) 安装失败，多半是软件包源的问题，请检查 !" && exit 1
        Check_python
        #echo "nameserver 8.8.8.8" > /etc/resolv.conf
        #echo "nameserver 8.8.4.4" >> /etc/resolv.conf
        \cp -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
        if [[ ${release} == "centos" ]]; then
                /etc/init.d/crond restart
        else
                /etc/init.d/cron restart
        fi
}

Check_Libsodium_ver(){
        echo -e "${Info} 开始获取 libsodium 最新版本..."
        Libsodiumr_ver=$(wget -qO- "https://github.com/jedisct1/libsodium/tags"|grep "/jedisct1/libsodium/releases/tag/"|head -1|sed -r 's/.*tag\/(.+)\">.*/\1/')
        [[ -z ${Libsodiumr_ver} ]] && Libsodiumr_ver=${Libsodiumr_ver_backup}
        echo -e "${Info} libsodium 最新版本为 ${Green_font_prefix}${Libsodiumr_ver}${Font_color_suffix} !"
}
Install_Libsodium(){
        if [[ -e ${Libsodiumr_file} ]]; then
                echo -e "${Error} libsodium 已安装 , 开始覆盖安装(更新)."
        else
                echo -e "${Info} libsodium 未安装，开始安装..."
        fi
        Check_Libsodium_ver
        if [[ ${release} == "centos" ]]; then
                yum update
                echo -e "${Info} 安装依赖..."
                yum -y groupinstall "Development Tools"
                echo -e "${Info} 下载..."
                wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/archive/${Libsodiumr_ver}/${Libsodiumr_ver}-RELEASE.tar.gz"
                echo -e "${Info} 解压..."
                tar -xzf ${Libsodiumr_ver}-RELEASE.tar.gz && cd libsodium-${Libsodiumr_ver}-RELEASE
                echo -e "${Info} 编译安装..."
                ./configure --disable-maintainer-mode && make -j2 && make install
                echo /usr/local/lib > /etc/ld.so.conf.d/usr_local_lib.conf
        else
                apt-get update
                echo -e "${Info} 安装依赖..."
                apt-get install -y build-essential
                echo -e "${Info} 下载..."
                wget  --no-check-certificate -N "https://github.com/jedisct1/libsodium/archive/${Libsodiumr_ver}/${Libsodiumr_ver}-RELEASE.tar.gz"
                echo -e "${Info} 解压..."
                tar -xzf ${Libsodiumr_ver}-RELEASE.tar.gz && cd libsodium-${Libsodiumr_ver}-RELEASE
                echo -e "${Info} 编译安装..."
                ./configure --disable-maintainer-mode && make -j2 && make install
        fi
        ldconfig
        cd .. && rm -rf libsodium-${Libsodiumr_ver}.tar.gz && rm -rf libsodium-${Libsodiumr_ver}
        [[ ! -e ${Libsodiumr_file} ]] && echo -e "${Error} libsodium 安装失败 !" && exit 1
        echo && echo -e "${Info} libsodium 安装成功 !" && echo
}

SSR_installation_status(){
	[[ ! -e ${ssr_folder} ]] && echo -e "${Error} 没有发现 ShadowsocksR 文件夹，请检查 !" && exit 1
}

check_pid(){
	PID=`ps -ef |grep -v grep | grep server.py |awk '{print $2}'`
}

Start_SSR(){
        SSR_installation_status
        check_pid
        [[ ! -z ${PID} ]] && echo -e "${Error} ShadowsocksR 正在运行 !" && exit 1
        /etc/init.d/ssrmu start
}

Install_Python_dependency(){
    if [[ ! -e ${pip3} ]]; then
	apt_get update    
        apt-get -y install python3-pip
        echo -e "pip3 安装完成，继续..." 
    else
        echo -e "pip3 已安装，继续..."
    fi
    if [[ ! -e ${pip} ]]; then
	apt_get update    
        apt-get -y install python-pip
        echo -e "pip 安装完成，继续..." 
    else
        echo -e "pip 已安装，继续..."
    fi
    pip3 install pymysql
    echo -e "pymysql安装完成，继续..."
    pip install cymysql
    echo -e "cymysql安装完成，继续..."
}

Install_SSR(){
        check_root
	check_syy
        [[ -e ${ssr_folder} ]] && echo -e "${Error} ShadowsocksR 文件夹已存在，请检查( 如安装失败或者存在旧版本，请先卸载 ) !" && exit 1
        echo -e "${Info} 开始安装/配置 ShadowsocksR依赖..."
        Installation_dependency
        echo -e "${Info} 开始下载/安装 Libsodium..."
	Install_Libsodium
	echo -e "${Info} 开始下载/安装 ShadowsocksR文件..."
        Download_SSR
        echo -e "${Info} 开始下载/安装 ShadowsocksR服务脚本(init)..."
        Service_SSR
        echo -e "${Info} 开始下载/安装 JSNO解析器 JQ..."
        JQ_install
	echo -e "${Info} 连接数据库更新ssr配置中..."
	Install_Python_dependency
	"${python3_ver}" "$getNodeId"
        echo -e "${Info} 所有步骤 安装完毕，开始启动 ShadowsocksR服务端..."
        Start_SSR
}

Set_latest_new_version(){
	echo -e "请输入 要下载安装的Linux内核版本(BBR) ${Green_font_prefix}[ 格式: x.xx.xx ，例如: 4.9.96 ]${Font_color_suffix}
${Tip} 内核版本列表请去这里获取：${Green_font_prefix}[ http://kernel.ubuntu.com/~kernel-ppa/mainline/ ]${Font_color_suffix}
建议使用${Green_font_prefix}稳定版本：4.9.XX ${Font_color_suffix}，4.9 以上版本属于测试版，稳定版与测试版同步更新，BBR 加速效果无区别。"
	# read -e -p "(直接回车，自动获取最新稳定版本):" latest_version
	[[ -z "${latest_version}" ]] && get_latest_new_version
	echo
}
# 本段获取最新版本的代码来源自: https://teddysun.com/489.html
get_latest_new_version(){
	echo -e "${Info} 检测稳定版内核最新版本中..."
	latest_version=$(wget -qO- -t1 -T2 "http://kernel.ubuntu.com/~kernel-ppa/mainline/" | awk -F'\"v' '/v4.9.*/{print $2}' |grep -v '\-rc'| cut -d/ -f1 | sort -V | tail -1)
	[[ -z ${latest_version} ]] && echo -e "${Error} 检测内核最新版本失败 !" && exit 1
	echo -e "${Info} 稳定版内核最新版本为 : ${latest_version}"
}
get_latest_version(){
	Set_latest_new_version
	bit=`uname -m`
	if [[ ${bit} == "x86_64" ]]; then
		deb_name=$(wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${latest_version}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/amd64.deb/{print $2}' | cut -d'<' -f1 | head -1 )
		deb_kernel_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${latest_version}/${deb_name}"
		deb_kernel_name="linux-image-${latest_version}-amd64.deb"
	else
		deb_name=$(wget -qO- http://kernel.ubuntu.com/~kernel-ppa/mainline/v${latest_version}/ | grep "linux-image" | grep "generic" | awk -F'\">' '/i386.deb/{print $2}' | cut -d'<' -f1 | head -1)
		deb_kernel_url="http://kernel.ubuntu.com/~kernel-ppa/mainline/v${latest_version}/${deb_name}"
		deb_kernel_name="linux-image-${latest_version}-i386.deb"
	fi
}
#检查内核是否满足
check_deb_off(){
	get_latest_new_version
	deb_ver=`dpkg -l|grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep '[4-9].[0-9]*.'`
	latest_version_2=$(echo "${latest_version}"|grep -o '\.'|wc -l)
	if [[ "${latest_version_2}" == "1" ]]; then
		latest_version="${latest_version}.0"
	fi
	if [[ "${deb_ver}" != "" ]]; then
		if [[ "${deb_ver}" == "${latest_version}" ]]; then
			echo -e "${Info} 检测到当前内核版本[${deb_ver}] 已满足要求，继续..."
		else
			echo -e "${Tip} 检测到当前内核版本[${deb_ver}] 支持开启BBR 但不是最新内核版本，可以使用${Green_font_prefix} bash ${file}/bbr.sh ${Font_color_suffix}来升级内核 !(注意：并不是越新的内核越好，4.9 以上版本的内核 目前皆为测试版，不保证稳定性，旧版本如使用无问题 建议不要升级！)"
		fi
	else
		echo -e "${Error} 检测到当前内核版本[${deb_ver}] 不支持开启BBR，请使用${Green_font_prefix} bash ${file}/bbr.sh ${Font_color_suffix}来更换最新内核 !" && exit 1
	fi
}
# 删除其余内核
del_deb(){
	deb_total=`dpkg -l | grep linux-image | awk '{print $2}' | grep -v "${latest_version}" | wc -l`
	if [[ "${deb_total}" -ge "1" ]]; then
		echo -e "${Info} 检测到 ${deb_total} 个其余内核，开始卸载..."
		for((integer = 1; integer <= ${deb_total}; integer++))
		do
			deb_del=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "${latest_version}" | head -${integer}`
			echo -e "${Info} 开始卸载 ${deb_del} 内核..."
			apt-get purge -y ${deb_del}
			echo -e "${Info} 卸载 ${deb_del} 内核卸载完成，继续..."
		done
		deb_total=`dpkg -l|grep linux-image | awk '{print $2}' | wc -l`
		if [[ "${deb_total}" = "1" ]]; then
			echo -e "${Info} 内核卸载完毕，继续..."
		else
			echo -e "${Error} 内核卸载异常，请检查 !" && exit 1
		fi
	else
		echo -e "${Info} 检测到除刚安装的内核以外已无多余内核，跳过卸载多余内核步骤 !"
	fi
}
del_deb_over(){
	# del_deb
	update-grub
	addsysctl
	echo -e "${Tip} 重启VPS后，请运行脚本查看 BBR 是否正常加载，运行命令： ${Green_background_prefix} bash ${file}/bbr.sh status ${Font_color_suffix}"
	echo -e "需要重启VPS后，才能开启BBR" 
}
# 安装BBR
installbbr(){
	check_root
	check_sys
	[[ ${release} != "debian" ]] && [[ ${release} != "ubuntu" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
	get_latest_version
	deb_ver=`dpkg -l|grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep '[4-9].[0-9]*.'`
	latest_version_2=$(echo "${latest_version}"|grep -o '\.'|wc -l)
	if [[ "${latest_version_2}" == "1" ]]; then
		latest_version="${latest_version}.0"
	fi
	if [[ "${deb_ver}" != "" ]]; then	
		if [[ "${deb_ver}" == "${latest_version}" ]]; then
			echo -e "${Info} 检测到当前内核版本[${deb_ver}] 已是最新版本，无需继续 !"
			deb_total=`dpkg -l|grep linux-image | awk '{print $2}' | grep -v "${latest_version}" | wc -l`
			if [[ "${deb_total}" != "0" ]]; then
				echo -e "${Info} 检测到内核数量异常，存在多余内核，开始删除..."
				del_deb_over
			else
				exit 1
			fi
		else
			echo -e "${Info} 检测到当前内核版本支持开启BBR 但不是最新内核版本，开始升级(或降级)内核..."
		fi
	else
		echo -e "${Info} 检测到当前内核版本不支持开启BBR，开始..."
		virt=`virt-what`
		if [[ -z ${virt} ]]; then
			apt-get update && apt-get install virt-what -y
			virt=`virt-what`
		fi
		if [[ ${virt} == "openvz" ]]; then
			echo -e "${Error} BBR 不支持 OpenVZ 虚拟化(不支持更换内核) !" && exit 1
		fi
	fi
	echo "nameserver 8.8.8.8" > /etc/resolv.conf
	echo "nameserver 8.8.4.4" >> /etc/resolv.conf
	
	wget -O "${deb_kernel_name}" "${deb_kernel_url}"
	if [[ -s ${deb_kernel_name} ]]; then
		echo -e "${Info} 内核安装包下载成功，开始安装内核..."
		dpkg -i ${deb_kernel_name}
		rm -rf ${deb_kernel_name}
	else
		echo -e "${Error} 内核安装包下载失败，请检查 !" && exit 1
	fi
	#判断内核是否安装成功
	deb_ver=`dpkg -l | grep linux-image | awk '{print $2}' | awk -F '-' '{print $3}' | grep "${latest_version}"`
	if [[ "${deb_ver}" != "" ]]; then
		echo -e "${Info} 检测到内核安装成功，开始卸载其余内核..."
		del_deb_over
	else
		echo -e "${Error} 检测到内核安装失败，请检查 !" && exit 1
	fi
}
bbrstatus(){
	check_bbr_status_on=`sysctl net.ipv4.tcp_congestion_control | awk '{print $3}'`
	if [[ "${check_bbr_status_on}" = "bbr" ]]; then
		echo -e "${Info} 检测到 BBR 已开启 !"
		# 检查是否启动BBR
		check_bbr_status_off=`lsmod | grep bbr`
		if [[ "${check_bbr_status_off}" = "" ]]; then
			echo -e "${Error} 检测到 BBR 已开启但未正常启动，请尝试使用低版本内核(可能是存着兼容性问题，虽然内核配置中打开了BBR，但是内核加载BBR模块失败) !"
		else
			echo -e "${Info} 检测到 BBR 已开启并已正常启动 !"
		fi
		exit 1
	fi
}
addsysctl(){
	sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf
	sed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf
	
	echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
	sysctl -p
}
startbbr(){
	check_deb_off
	bbrstatus
	addsysctl
	sleep 1s
	bbrstatus
}
# 关闭BBR
stopbbr(){
	check_deb_off
	sed -i '/net\.core\.default_qdisc=fq/d' /etc/sysctl.conf
	sed -i '/net\.ipv4\.tcp_congestion_control=bbr/d' /etc/sysctl.conf
	sysctl -p
	sleep 1s
	
	read -e -p "需要重启VPS后，才能彻底停止BBR，是否现在重启 ? [Y/n] :" yn
	[[ -z "${yn}" ]] && yn="y"
	if [[ $yn == [Yy] ]]; then
		echo -e "${Info} VPS 重启中..."
		reboot
	fi
}
# 查看BBR状态
statusbbr(){
	check_deb_off
	bbrstatus
	echo -e "${Error} BBR 未开启 !"
}

#设置v2ray定时升级任务
planUpdate(){
    	if [[ $CHINESE == 1 ]];then
        	#计算北京时间早上3点时VPS的实际时间
        	ORIGIN_TIME_ZONE=$(date -R|awk '{printf"%d",$6}')
        	LOCAL_TIME_ZONE=${ORIGIN_TIME_ZONE%00}
        	BEIJING_ZONE=8
        	DIFF_ZONE=$[$BEIJING_ZONE-$LOCAL_TIME_ZONE]
        	LOCAL_TIME=$[$BEIJING_UPDATE_TIME-$DIFF_ZONE]
        	if [ $LOCAL_TIME -lt 0 ];then
         	   LOCAL_TIME=$[24+$LOCAL_TIME]
        	elif [ $LOCAL_TIME -ge 24 ];then
       	  	   LOCAL_TIME=$[$LOCAL_TIME-24]
        	fi
        	colorEcho ${BLUE} "beijing time ${BEIJING_UPDATE_TIME}, VPS time: ${LOCAL_TIME}\n"
    	else
        	LOCAL_TIME=3
    	fi
    	OLD_CRONTAB=$(crontab -l)
    	echo "SHELL=/bin/bash" >> crontab.txt
    	echo "${OLD_CRONTAB}" >> crontab.txt
		echo "0 ${LOCAL_TIME} * * * bash <(curl -L -s https://install.direct/go.sh) | tee -a /root/v2rayUpdate.log && service v2ray restart" >> crontab.txt
		crontab crontab.txt
		sleep 1
		if [[ ${OS} == 'CentOS' || ${OS} == 'Fedora' ]];then
        	service crond restart
		else
			service cron restart
		fi
		rm -f crontab.txt
		colorEcho ${GREEN} "success open schedule update task: beijing time ${BEIJING_UPDATE_TIME}\n"
}

install_v2ray(){
	apt-get install -y curl
    	bash <(curl -L -s https://install.direct/go.sh)
	planUpdate
	wget https://github.com/kencin/MyLinuxInit/raw/master/v2ray/v2ray.zip && unzip v2ray.zip && mv v2ray/* /etc/v2ray && rm -rf v2ray/
	"${python3_ver}" /etc/v2ray/v2rayPython/uploadV2rayConf.py
	"${python3_ver}" /etc/v2ray/v2rayPython/modifyV2rayConf.py
	service v2ray restart
}

#check_root
Install_SSR
#installbbr
install_v2ray
#reboot
