#!/bin/bash

function Calculation
{
    # Array containing pid's of all processes.
    pid_array=`ls /proc | grep -E '^[0-9]+$'`

    # Number of clock ticks per second.
    clock_ticks=`getconf CLK_TCK`

    # Total Memory Available in the system.
    total_mem=`awk '/MemTotal/ { print $2 }' /proc/meminfo`

    # Initialing a data file that is used to display.
    cat /dev/null > data

    #Iterating through all processes.

    for pid in $pid_array
    do
        if [ -r /proc/$pid/stat ]
        then

            # User info 
            user_id=`awk '/Uid/{print $2}' /proc/$pid/status`
            user=`id -nu $user_id`

            #The Command name associated with the process
            comm=`cat /proc/$pid/comm`

            # Data relate to /proc/uptime
            uptime_array=( `cat /proc/uptime` )
            uptime=${uptime_array[0]}

            # Data related to /proc/[pid]/stat
            stat_array=( `cat /proc/$pid/stat` )

            state=${stat_array[2]}
            ppid=${stat_array[3]}
            priority=${stat_array[17]}
            nice=${stat_array[18]}

            utime=${stat_array[13]}
            stime=${stat_array[14]}
            cutime=${stat_array[15]}
            cstime=${stat_array[16]}
            num_threads=${stat_array[19]}
            starttime=${stat_array[21]}

            #Data related to /proc/[pid]/statm
            statm=`cat /proc/$pid/statm`
            statm_array=(${statm})

            resident=${statm_array[1]}
            data_and_stack=${statm_array[5]}

            #Calculation
    
            #CPU usage
            total_time=`expr $utime + $stime`
            total_time=`expr $total_time + $cutime`
            seconds=$( awk 'BEGIN {print ( '$uptime' - ('$starttime' / '$clock_ticks') )}' )
            cpu_usage=$( awk 'BEGIN {print ( 100 * (('$total_time' / '$clock_ticks') / '$seconds') )}' )
            
            #Memory usage
            memory_usage=$( awk 'BEGIN {print( (('$resident' + '$data_and_stack' ) * 100) / '$total_mem'  )}' )
            printf "%-6d %-6d %-10s %-4d %-5d %-4s %-4u %-7.2f %-7.2f %-18s\n" $pid $ppid $user $priority $nice $state $num_threads $memory_usage $cpu_usage $comm >> data
        fi
    done
    
    clear
    printf "\e[30;107m%-6s %-6s %-10s %-4s %-3s %-6s %-4s %-7s %-7s %-18s\e[0m\n" "PID" "PPID" "USER" "PR" "NI" "STATE" "THR" "%MEM" "%CPU" "COMMAND"
    sort -nr -k9 data | head -$1
}

while true
do
    terminal_height=$(tput lines)
    lines=$(( $terminal_height - 3 ))
    Calculation $lines
done
