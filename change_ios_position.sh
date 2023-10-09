#!/bin/bash

# 生成随机后缀
random_suffix=$(date +%s%N | shasum -a 256 | head -c 10)

# 构建新的输出文件名
new_output_file="command_output_${random_suffix}.txt"


# 定义要查找的命令
target_command="sudo python3 -u -m pymobiledevice3 remote start-quic-tunnel"

# 使用pgrep查找相关进程的PID
pids=$(ps -ef | grep "start-quic-tunnel" | grep -v grep | awk '{print $2 }')

# 检查是否找到相关进程
if [ -n "$pids" ]; then
    # 循环终止每个进程
    for pid in $pids; do
        sudo kill "$pid"
        echo "已终止进程 $pid"
    done
else
    echo "未找到相关进程"
fi


# 后台执行命令并将其存储到变量中
nohup sudo python3 -u -m pymobiledevice3 remote start-quic-tunnel > "$new_output_file" 2>&1 &
command_pid=$!  # 获取后台命令的PID
echo "Command PID: $command_pid"

# 等待直到获取RSD Address和RSD Port
while true; do
    # 检查后台命令是否已经完成
    if ! ps -p $command_pid > /dev/null; then
        echo "Command has finished"
        break
    fi
    input_file=$(cat "$new_output_file" | sed -r "s/\x1B\[[0-9;]*[mK]//g")
    echo "$input_file"
    echo "Waiting for RSD Address and RSD Port..."
    rsd_address=$(echo "$input_file" | grep -oE 'RSD Address: [^ ]+' | awk '{print $3}')
    rsd_port=$(echo "$input_file" | grep -oE 'RSD Port: [0-9]+' | awk '{print $3}')
    
    # 如果已经获取到RSD Address和RSD Port，则退出循环
    if [ -n "$rsd_address" ] && [ -n "$rsd_port" ]; then
        break
    fi
    # 等待一段时间后重新检查
    sleep 5
done

# 打印提取的值
echo "RSD Address: $rsd_address"
echo "RSD Port: $rsd_port"

# 挂载Developer Disk Image
sudo pymobiledevice3 mounter auto-mount

# 修改虚拟位置
latitude="$1"
longitude="$2"
echo "Latitude: $latitude"
echo "Longitude: $longitude"

# 使用RSD Address和RSD Port设置虚拟位置
pymobiledevice3 developer dvt simulate-location set --rsd "$rsd_address" "$rsd_port" -- "$latitude" "$longitude"

# 结束后台命令
kill "$command_pid"
rm "$new_output_file"