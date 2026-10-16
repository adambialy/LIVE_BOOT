#!/bin/bash
CPUNO=$((`lscpu | grep 'CPU(s):' | head -n 1 | awk '{print $2}'`-2))
stress-ng --cpu ${CPUNO} --cpu-load ${1} --timeout ${2}
