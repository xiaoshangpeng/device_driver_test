#!/bin/sh

set -x

LOCAL_PID=`echo $$`

LOCAL_PROGRAM=$1
LOCAL_COMMAND=$2
LOCAL_TIMES=$3
LOCAL_PRIORITY=$4

test -f $PRIORITY_DONE.$LOCAL_PROGRAM && rm $PRIORITY_DONE.$LOCAL_PROGRAM

cat /proc/$LOCAL_PID/sched | grep se.sum_exec_runtime > $PROCFS_PID_SCHED_START.$LOCAL_PROGRAM

$UTILBIN/scheduler_priority_set $LOCAL_PID $LOCAL_PRIORITY

while [ -d "/proc/$LOCAL_PID" ]
do

	count=0
	while [ $count -lt $LOCAL_TIMES ]
	do
		eval $LOCAL_COMMAND
		echo "$LOCAL_PID | $count"
		cat /proc/$LOCAL_PID/sched | grep se.sum_exec_runtime > $PROCFS_PID_SCHED_CURRENT.$LOCAL_PROGRAM
		count=`expr $count + 1`
	done

	echo "$LOCAL_PID `cat $PROCFS_PID_SCHED_START.$LOCAL_PROGRAM`"
	echo "$LOCAL_PID `cat $PROCFS_PID_SCHED_CURRENT.$LOCAL_PROGRAM`"

	touch $PRIORITY_DONE.$LOCAL_PROGRAM
	break

done
