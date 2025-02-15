#!/bin/sh

sleeptime=30
logfile="/var/log/dnscache.file"
adg_logfile="/etc/AdGuardHome/data/querylog.json"
dns_enable=$(uci get sfe.config.dns 2>/dev/null)
dnscache_enable=$(uci get sfe.config.dnscache_enable 2>/dev/null)

clean_log(){
logrow=$(grep -c "" ${logfile})
if [ $logrow -ge 500 ];then
    cat /dev/null > ${logfile}
    echo "$curtime Log条数超限，清空处理！" >> ${logfile}
fi
if [ $dnscache_enable = "3" ];then
    adg_logrow=$(grep -c "" ${adg_logfile})
    if [ $adg_logrow -ge 500 ];then
        cat /dev/null > ${adg_logfile}
        echo "$curtime Log条数超限，清空处理！" >> ${adg_logfile}
    fi
fi

}

while [ $dns_enable -eq 1 ];
do
curtime=`date "+%H:%M:%S"`
echo "$curtime online! "
if [ $dns_enable -eq 1 ]; then
	if [ $dnscache_enable = "3" ];  then
		if ! pidof AdGuardHome>/dev/null; then
			AdGuardHome -c /etc/AdGuardHome/AdGuardHome.yaml -w /etc/AdGuardHome &
			echo "$curtime 重启服务！" >> ${logfile}
		fi
	else
		if ! pidof dnscache>/dev/null; then
			if [ $dnscache_enable = "1" ];  then
			/usr/sbin/dnscache -c /var/etc/dnscache.conf &
			elif [ $dnscache_enable = "2" ];  then
			dnscache -f /var/run/dnscache/dnscache.conf &
			fi
			echo "$curtime 重启服务！" >> ${logfile}
		fi
	fi
fi

sleep ${sleeptime}
continue
done
