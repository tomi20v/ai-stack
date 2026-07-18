#!/bin/bash

clear
echo "=========================================================================================="
echo "                            Full Hardware & Fan Monitor (5s)                              "
echo "=========================================================================================="
echo "Press [CTRL+C] to exit."
echo ""

while true; do
    TIMESTAMP=$(date "+%H:%M:%S")

    # 1. CPU Temperature
    CPU_TEMP=$(sensors 2>/dev/null | awk '/(Package id 0|Tctl|CPU Temp)/ {print $2}' | head -n 1)

    # 2. Motherboard System Temp
    MOBO_TEMP=$(sensors 2>/dev/null | awk '/(Sys Temp|System|MB Temp|temp1)/ {print $2}' | head -n 1)
    [ -z "$MOBO_TEMP" ] && MOBO_TEMP="N/A"

    # 3. Fan Speeds (RPM)
    FAN_SPEEDS=$(sensors 2>/dev/null | grep -E 'fan[0-9]|CPU Fan|Sys Fan' | awk '{print $1 " " $2 " " $3}' | tr '\n' '  ')
    [ -z "$FAN_SPEEDS" ] && FAN_SPEEDS="No Fan Sensors Detected"

    # 4. GPU Metrics via nvidia-smi
    if command -v nvidia-smi &> /dev/null; then
        GPU_DATA=$(nvidia-smi --query-gpu=temperature.gpu,fan.speed,power.draw --format=csv,noheader,nounits 2>/dev/null)
        IFS=',' read -r GPU_TEMP GPU_FAN GPU_PWR <<< "$GPU_DATA"
        GPU_STR="${GPU_TEMP}°C | Fan: ${GPU_FAN}% | ${GPU_PWR}W"
    else
        GPU_STR="N/A"
    fi

    # Formatted Terminal Output
    printf "[%s]\n" "$TIMESTAMP"
    printf "  ��� CPU: %-8s | GPU: %s\n" "$CPU_TEMP" "$GPU_STR"
    printf "  ��� Mobo Temp: %-4s\n" "$MOBO_TEMP"
    printf "  ��� Fans: %s\n\n" "$FAN_SPEEDS"

    # 5. Ollama Processes
    if command -v ollama &> /dev/null; then
        echo "--- Ollama Processes ---"
        ollama ps
        echo "------------------------"
        echo ""
    fi

    sleep 5
done
