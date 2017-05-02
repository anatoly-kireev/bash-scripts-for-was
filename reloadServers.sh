#!/bin/sh

stop_command="/opt/IBM/WebSphere/AppServer/profiles/AppSrv01/bin/stopServer.sh"
stop_params="-username <was_admin> -password <was_admin_password>"
start_command="/opt/IBM/WebSphere/AppServer/profiles/AppSrv01/bin/startServer.sh"

server_names=(server1 server2 server3)
server_pid_root="/opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs/"

start_server () {
        s_name=$1
        echo "Starting server" $s_name
        $start_command $s_name
        start_res=$?
        if [ $start_res -eq 0 ]
        then
                echo "Server" $s_name "start complete."
        else
                echo "Error ocurred while restarting server" $s_name
                exit 1
        fi
}

stop_server () {
        s_name=$1
        s_pid=$2
        s_pid_file=$3
        echo "Stopping server" $s_name". Server pid is:" $s_pid
        $stop_command $s_name $stop_params
        stop_res=$?
        if [ $stop_res -eq 0 ]
        then
                echo "Server" $s_name "stopped successfully."
                sleep 1m
        else
                echo "Server" $s_name "failed to stop. Will allow 20 minutes to finish."
                sleep 20m
                echo "Restoring process."
                if [ -f $s_pid_file ]
                then
                        echo "Server is not willing to stop. Will kill pid:" $s_pid
                        kill -9 $s_pid
                        echo "Server killed!"
                else
                        echo "Server" $s_name "finally stopped."
                fi
        fi
}

for i in ${server_names[@]}; do
        server_name=${i}
        server_pid_file=$server_pid_root${i}"/"${i}".pid"
        if [ -f $server_pid_file ]
        then
                server_pid=$(cat $server_pid_file)
                stop_server $server_name $server_pid $server_pid_file
                start_server $server_name
        else
                echo "Server not started"
                start_server $server_name
        fi
        sleep 1m
done
