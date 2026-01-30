#!/bin/bash

echo -e "Basic Server Performance Stats \n"

# Get Memory Info

echo "------------Memory------------"

read totalMemory freeMemory < <(
  vmstat -sS M | awk '
    /total memory/ { total=$1 }
    /free memory/  { free=$1 }
    END { print total, free }
  '
)

usedMemory=$(( totalMemory-freeMemory))
percentFree=$(awk -v free="$freeMemory" -v total="$totalMemory" 'BEGIN {printf "%.2f", free/total*100}')
percentUsed=$(awk -v used="$usedMemory" -v total="$totalMemory" 'BEGIN {printf "%.2f", used/total*100}')

echo "Total memory: $totalMemory  MB "
echo "Free memory: $freeMemory  MB - $percentFree% unused"
echo "Used memory: $usedMemory MB - $percentUsed% used"

echo -e "\n"
echo "------------CPU------------"
cpuUsage=$(vmstat 1 2 | awk 'NR==4 { print 100 - $15 }')
echo "CPU Usage: $cpuUsage%"
