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

usedMemory=$((totalMemory-freeMemory))
percentFree=$(awk -v free="$freeMemory" -v total="$totalMemory" 'BEGIN {printf "%.2f", free/total*100}')
percentUsed=$(awk -v used="$usedMemory" -v total="$totalMemory" 'BEGIN {printf "%.2f", used/total*100}')

echo "Total memory: $totalMemory MB "
echo "Free memory: $freeMemory MB - $percentFree% unused"
echo "Used memory: $usedMemory MB - $percentUsed% used"

# Get CPU Usage

echo -e "\n"
echo "------------CPU------------"

#### vmstat with 1 second delay with 2 measurements, because first measurement would be since boot ####
#### awl take row 4 (last row) and calculate 100 (max usage) - idle cpu (column 15) ####

cpuUsage=$(vmstat 1 2 | awk 'NR==4 { printf "%.2f", 100 - $15 }')
echo "CPU Usage: $cpuUsage%"

# Get Disk Info

echo -e "\n"
echo ""------------Disk"------------"

read totalDiskSize freeDiskSize < <(
    df -T | grep "ext4" | awk '{total=$3/1000000000} {free=$5/1000000000} END {printf "%.2f %.2f", total, free}
    '
)

usedDiskSize=$(awk -v total="$totalDiskSize" -v free="$freeDiskSize" 'BEGIN {printf "%.2f", total-free}')

echo "Total disk size: $totalDiskSize TB"
echo "Free disk size: $freeDiskSize TB"
echo "Used disk size: $usedDiskSize TB"

echo -e "\n"

#### Get Top 5 Processes by CPU usage ####

echo "Top 5 Processes by CPU% Usage"

# get the 5 process ids with the highest cpu usage
cpuPids=$(ps -eo pid --sort=-%cpu --no-headers | head -n 5)

# output some details about the processes
ps -o uid,pid,%cpu,comm --sort=-%cpu -p $cpuPids


echo -e "\n"

#### Get Top 5 by RAM usage ####

echo "Top 5 Processes by MEM% Usage"

# get the 5 processes with the highest mem usage
memPids=$(ps -eo pid --sort=-%mem --no-headers | head -n 5)

# output some details about the processes
ps -o uid,pid,%mem,comm --sort=-%mem -p $memPids