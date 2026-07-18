#!/bin/bash

# Initial clear of the screen
clear

# Print the Big Header starting from line 6 to avoid being overwritten by the Ollama area
# We use tput cup 5 0 to ensure it starts after the reserved 5 rows.
tput cup 5 0
echo "=========================================================================================="
echo "                            Full Hardware & Fan Monitor (5s)                              "
echo "=========================================================================================="
echo "Press [CTRL+C] to exit."
echo ""

while true; do
    # 1. Hardware Metrics (Appending to scrollback)
    TIMESTAMP=$(date "+%H:%M:%S")

    # CPU Temperature
    CPU_TEMP=$(sensors 2>/dev/null | awk '/(Package id 0|Tctl|CPU Temp)/ {print $2}' | head -n 1)

    # Motherboard System Temp
    MOBO_TEMP=$(sensors 2>/dev/null | awk '/(Sys Temp|System|MB Temp|temp1)/ {print $2}' | head -n 1)
    [ -z "$MOBO_TEMP" ] && MOBO_TEMP="N/A"

    # Fan Speeds (RPM)
    FAN_SPEEDS=$(sensors 2>/dev/null | grep -E 'fan[0-9]|CPU Fan|Sys Fan' | awk '{print $1 " " $2 " " $3}' | tr '\n' '  ')
    [ -z "$FAN_SPEEDS" ] && FAN_SPEEDS="N/A"

    # GPU Metrics via nvidia-smi
    if command -v nvidia-smi &> /dev/null; then
        GPU_DATA=$(nvidia-smi --query-gpu=temperature.gpu,fan.speed,power.draw --format=csv,noheader,nounits 2>/dev/null)
        IFS=',' read -r GPU_TEMP GPU_FAN GPU_PWR <<< "$GPU_DATA"
        GPU_STR="${GPU_TEMP}°C | Fan: ${GPU_FAN}% | ${GPU_PWR}W"
    else
        GPU_STR="N/A"
    fi

    # Print the hardware metric line to the bottom of the screen (appending to scrollback)
    printf "[%s] CPU: %-8s | GPU: %s | Mobo: %-4s | Fans: %s\n" "$TIMESTAMP" "$CPU_TEMP" "$GPU_STR" "$MOBO_TEMP" "$FAN_SPEEDS"

    # 2. Update Ollama Area (Fixed window: lines 1-5)
    tput sc               # Save current cursor position in the scrolling log
    tput cup 0 0          # Jump to the very top of the terminal

    # Clear lines 1 through 5 specifically
    printf "\033[1;1H\033[5;1J"

    if command -v ollama &> /dev/null; then
        ollama ps | head -n 5
    else
        echo "Ollama not found"
    fi
    tput rc               # Restore cursor back to the scrolling log position

    sleep 5
done
