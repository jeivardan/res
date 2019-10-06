# res
Basic command line based Resource Monitor for UNIX systems.

# Preparation

### To Calculate CPU usage for a specefic process you'll need the following:

1. #### ```/proc/uptime```
    - uptime of the system (seconds)

2. #### ```/proc/[PID]/stat```
    - ```#14 utime``` - CPU time spent in user code, measured in clock ticks
    - ```#15 stime``` - CPU time spent in kernel code, measured in clock ticks
    - ```#16 cutime``` - Waited-for children's CPU time spent in user code (in clock ticks)
    - ```#17 cstime``` - Waited-for children's CPU time spent in kernel code (in clock ticks)
    - ```#22 starttime``` - Time when the process started, measured in clock ticks

3. #### ```Hertz (number of clock ticks per second) of your system.```
    - In most cases, [getconf CLK_TCK](http://pubs.opengroup.org/onlinepubs/009695399/utilities/getconf.html) can be used to return the number of clock ticks.

### To Calculate the memory usage for a specefic process you'll need the following:

1. #### ```/proc/meminfo```
    - ```#1 MemTotal``` -  Total usable RAM (i.e., physical RAM minus a few reserved bits and the kernel binary code).

2. #### ```/proc/[PID]/statm```
    - ```#2 resident set size(rss)``` - the portion of memory occupied by a process that is held in main memory(as Pages).
    - ```#6 data``` - data + stack.

### Reference

proc(5) - [Linux manual page](http://man7.org/linux/man-pages/man5/proc.5.html)

# Calculation

### CPU Usage

    total_time = utime + stime
    
    total_time = total_time + cutime + cstime
    
    seconds = uptime - (starttime / Hertz)
    
    cpu_usage = 100 * ((total_time / Hertz) / seconds)

### Memory Usage

    rss = resident set size.
    
    data = data + stack.

    total_mem = MemTotal.

    memory_usage = ((rss + data) * 100) / total_mem
