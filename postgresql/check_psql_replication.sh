#!/bin/bash

timeout=600
version=9.1

last=$(/usr/lib/postgresql/$version/bin/pg_controldata /var/lib/postgresql/$version/main | grep "Time of latest checkpoint" | sed "s/.*checkpoint: *//")
last_timestamp=$(date --date="$last" +%s)
now_timestamp=$(date +%s)
diff=$(($now_timestamp - $last_timestamp))

if [ $diff -gt $timeout ] && [ "$(su -l postgres -c "psql t -A -F \  -c select\ pg_is_xlog_replay_paused\(\)")" = 'f' ]; then
        echo "No replication since $diff seconds | time=${diff}s ok=0"
        exit 2
fi
echo "Replication OK | time=${diff}s ok=1"
exit 0

