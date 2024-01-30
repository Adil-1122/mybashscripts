#!/bin/bash
servers=("10.202.0.102" "10.202.0.113" "10.202.0.114")
servers1=("2" "3" "4")
yesterday="$(date -d '-1 day' '+%Y%m%d')"
timestamp="$(date +'%d-%m-%Y-%H:%M:%S')"

#############HealthLogs for app1###########################

touch /home/admin/scratch/tpsCheck/app1-$yesterday-00-23-tpsStats.csv
for i in {00..23};do
    cat /home/admin/scratch/tpsCheck/app1-$yesterday-$i-tpsStats.csv | grep -v 'Date,TimeInSecond,TPS' >> /home/admin/scratch/tpsCheck/app1-$yesterday-00-23-tpsStats.csv
done
cp /home/admin/scratch/monitoring/monitor_$yesterday.csv /home/admin/adil/tmp/app1_monitor_$yesterday.csv
cp /home/admin/scratch/error_response/app1_ReponseCode_$yesterday.csv /home/admin/adil/tmp/logs/app1_ReponseCode_$yesterday.csv

##########HealthLogs for app2, app3 app4###########

local_dir="/path/to/your/local/directory"

for i in ${!servers[@]}; do
    ssh admin@${servers[$i]} << EOF
    if [ \$? -eq 0 ]; then
        # Remote file path
        remote_file="/home/admin/scratch/tpsCheck/app${servers1[$i]}-$yesterday-00-23-tpsStats.csv"
        
        # Create file on remote server
        touch \$remote_file
        
        # Populate the file on remote server
        for j in {00..23}; do
            cat /home/admin/scratch/tpsCheck/app${servers1[$i]}-$yesterday-\$j-tpsStats.csv | grep -v 'Date,TimeInSecond,TPS' >> \$remote_file
        done
        
        # Copy file from remote server to local machine using scp
        scp \$remote_file admin@your_local_machine_ip:$local_dir
        
        if [ \$? -eq 0 ]; then
            echo "[App${servers1[$i]} $timestamp] File created and copied successfully" >> /home/admin/adil/tmp/logs/nodes_stats_logs.log
        else
            echo "[App${servers1[$i]} $timestamp] File creation or copy failed" >> /home/admin/adil/tmp/logs/nodes_stats_logs.log
        fi
    else
        echo "[App${servers1[$i]} $timestamp] server not connected" >> /home/admin/adil/tmp/logs/nodes_stats_logs.log
        exit
    fi
EOF
done





