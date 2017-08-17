#!/bin/bash 

# Creates an instance of 2 processes

SCRIPT="<name-of-script-or-binary>"
RUNAS="<user-to-run-command>"
worker_ids=( "worker1.pid" "worker2.pid" )
LOGFILE="<path-to-log>"

start() {
    echo 'Starting processes...' >&2
    for p in ${worker_ids[@]};do
        if [ -f "/var/run/${p}" ] && kill -0 $(cat "/var/run/${p}"); then
                echo 'Service already running' >&2
                return 1
        fi 
        local CMD="nohup $SCRIPT &>> \"$LOGFILE\" & echo \$!"
        su -c "$CMD" $RUNAS > "/var/run/${p}"
    done
    echo 'Service started' >&2
}

stop() {
    echo 'Stopping processes...' >&2
    for sp in ${worker_ids[@]};do
        if [ ! -f "/var/run/${sp}" ] || ! kill -0 $(cat "/var/run/${sp}"); then
                echo 'Service not running' >&2
                return 1
        fi 
        kill -15 $(cat "/var/run/${sp}") && rm -f "/var/run/${sp}"
    done
    echo 'Service stopped' >&2
}

status() {
        WPIDS=()
        index=0
        echo 'Checking service state...' >&2 
        for ppid in ${worker_ids[@]};do
                if [ ! -f "/var/run/${ppid}" ] || ! kill -0 $(cat "/var/run/${ppid}"); then
                        echo 'Service is not running' >&2
                        return 1
                fi 
                if [ -f "/var/run/${ppid}" ]; then
                        pv=$(cat "/var/run/${ppid}")
                        WPIDS[$index]=$pv
                        ((++index))
                fi
        done
        echo 'Service is running:' ${WPIDS[@]}
        return 0                
}
case "$1" in 
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        stop
        start 
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
esac
