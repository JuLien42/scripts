#!/bin/sh


master_host=db-01
slave_host=db-02

version=9.1

#
# /etc/fstab
#
# tmpfs           /var/lib/postgresql/${version}/main/pg_stat_tmp        tmpfs   size=256m       0       1
#
########################################

if [ $(id -u) -ne 0 ]; then
        echo 'run this script as root'
        exit 2
fi

if [ "$master_host" != "$HOSTNAME" ]; then
        echo "execute on master host only"
        exit 2
fi

ssh ${slave_host} "/etc/init.d/postgresql stop ; umount /var/lib/postgresql/${version}/main/pg_stat_tmp ; mv /var/lib/postgresql/${version}/main/ /var/lib/postgresql/${version}/main-$(date +%F)_$(date +%N) ; rm /var/lib/postgresql/wals/${master_host}/*"

echo "SELECT pg_start_backup('backup', true)" | su postgres -c psql
rsync -avz --exclude postmaster.pid  /var/lib/postgresql/${version}/main ${slave_host}:/var/lib/postgresql/${version}/
echo "SELECT pg_stop_backup()" | su postgres -c psql

ssh ${slave_host} "rm /var/lib/postgresql/${version}/main/pg_xlog/0* ; cp /var/lib/postgresql/${version}/recovery.done /var/lib/postgresql/${version}/main/recovery.conf ; chown postgres. /var/lib/postgresql/${version}/main/recovery.conf ; mount /var/lib/postgresql/${version}/main/pg_stat_tmp ; /etc/init.d/postgresql start"

