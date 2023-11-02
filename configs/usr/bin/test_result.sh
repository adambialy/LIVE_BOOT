#!/bin/bash

if [ "$2" == "more" ]; then
	if [ "`cat $1`" -ge "$3" ]; then
		echo OK;
	else
		echo ERR
	fi
fi

if [ "$2" == "less" ]; then
	if [ "`cat $1`" -le "$3" ]; then
		echo OK;
	else
		echo ERR
	fi
fi

if [ "$2" == "time" ]; then
	stat -c %y $1 | date +%Y.%m.%d-%H:%M
fi

