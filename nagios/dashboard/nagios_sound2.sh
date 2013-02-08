#!/bin/bash
##############################
# JuLien42
#
# Get coffeeSaint sound and play it
#
# http://mathias-kettner.de/checkmk_livestatus.html
##############################
# CONFIG
##############################

CONF_FILE=/etc/coffeesaint/coffeesaint.conf
REPEAT_SOUND=10 # minutes
WORKHOURS_START=8
WORKHOURS_END=19
WORKDAYS="1 2 3 4 5"
##############################
##############################

function check_workhours {
	day=$(date +%u)
	workhours=0
	for checkdate in $WORKDAYS; do
		if [ $checkdate -eq $day ]; then
			workhours=1
		fi
	done
	if [ ! $workhours ]; then
		echo 1
		return
	fi
	hour=$(date +%H)
	if [ $hour -ge $WORKHOURS_START ] && [ $hour -le $WORKHOURS_END ]; then
		echo 0
	else
		echo 1
	fi
	return
}

function play_sound {
	if [ $(check_workhours) ]; then
	        mplayer $(cat $CONF_FILE | grep sound | awk '{print $3}') &
	fi
}

lasterror=0
while [ 1 ]; do
	error=0
	sources=$(cat $CONF_FILE | grep source | awk '{print $5}')
	for source in $sources; do
		return=$(echo -e "GET services\nColumns: host_name description state\nFilter: state != 0\nFilter: acknowledged = 0\nFilter: notifications_enabled = 1\nFilter: acknowledged != 1\n" | nc $source 6557)
		if [ "$return" != "" ]; then
			error=1
		fi
	done

	if [ $error -eq 1 ] && [ $lasterror -eq 0 ]; then
		lastdate=$(date +%s)
		play_sound
	elif  [ $error -eq 1 ] && [ $(date +%s) -ge $(($lastdate + ($REPEAT_SOUND * 60))) ]; then
		lastdate=$(date +%s)
		play_sound
	fi
	lasterror=$error
	sleep 10
done

