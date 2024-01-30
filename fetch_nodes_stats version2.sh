#!/bin/bash
servers=("10.202.0.101" "10.202.0.102" "10.202.0.113" "10.202.0.114")
servers1=("1" "2" "3" "4")
yesterday="$(date -d '-1 day' '+%Y%m%d')"
timestamp="$(date +'%d-%m-%Y-%H:%M:%S')"
local_dir="/home/admin/adil/tmp/"

##########HealthLogs for app1, app2, app3, app4###########

for i in ${!servers[@]}; do
    if [ "${servers[$i]}" == "10.202.0.101" ]; then
        touch /home/admin/scratch/tpsCheck/app1-$yesterday-00-23-tpsStats.csv
        for j in {00..23}; do
            cat /home/admin/scratch/tpsCheck/app1-$yesterday-$j-tpsStats.csv | grep -v 'Date,TimeInSecond,TPS' >> /home/admin/scratch/tpsCheck/app1-$yesterday-00-23-tpsStats.csv
        done

        cp /home/admin/scratch/monitoring/monitor_$yesterday.csv /home/admin/adil/tmp/app1_monitor_$yesterday.csv
        cp /home/admin/scratch/error_response/app1_ReponseCode_$yesterday.csv /home/admin/adil/tmp/logs/app1_ReponseCode_$yesterday.csv
        cp /home/admin/scratch/tpsCheck/app1-$yesterday-00-23-tpsStats.csv /home/admin/adil/tmp/app1-$yesterday-00-23-tpsStats.csv
    else
        ssh admin@${servers[$i]} << EOF
        if [ \$? -eq 0 ]; then
            remote_file="/home/admin/scratch/tpsCheck/app${servers1[$i]}-$yesterday-00-23-tpsStats.csv"
            
            touch \$remote_file
            
            for j in {00..23}; do
                cat /home/admin/scratch/tpsCheck/app${servers1[$i]}-$yesterday-\$j-tpsStats.csv | grep -v 'Date,TimeInSecond,TPS' >> \$remote_file
            done
            
            
            
            if [ \$? -eq 0 ]; then
                echo "[App${servers1[$i]} $timestamp] File created and copied successfully" >> /home/admin/adil/tmp/logs/nodes_stats_logs.log
            else
                echo "[App${servers1[$i]} $timestamp] File creation or copy failed" >> /home/admin/adil/tmp/logs/nodes_stats_logs.log
            fi
        else
            echo "[App${servers1[$i]} $timestamp] Server not connected" >> /home/admin/adil/tmp/logs/nodes_stats_logs.log
            exit
            scp admin@\${!servers[@]}:\$remote_file \$local_dir
        fi
EOF
    fi
done
