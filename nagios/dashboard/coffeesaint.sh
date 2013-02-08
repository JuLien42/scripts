#!/bin/sh


sleep 10

cd /etc/coffeesaint/
sudo java -jar CoffeeSaint.jar --listen-port 1234 --config /etc/coffeesaint/coffeesaint.conf &

sleep 10
export DISPLAY=:0.0
metacity --replace &


/sbin/nagios_sound.sh &
