#!/bin/bash

LOG="input_parsed_$(date +%Y%m%d_%H%M%S).log"

if [ ! -d /proc/bus/input ]; then
    echo "❌ /proc/bus/input не найден" > "$LOG"
    exit 1
fi

{
    echo "[$(date)] Анализ устройств ввода..."
    printf "%-12s %-30s %-20s %-20s %s\n" "DEVICE" "NAME" "PHYS" "UNIQ" "HANDLER"
    echo "------------------------------------------------------------------------"
} > "$LOG"

while IFS= read -r line; do
    if [[ $line =~ ^I:[[:space:]]* ]]; then
        dev=$(echo "$line" | awk '{print $NF}')
        handler="/dev/input/$dev"
    elif [[ $line =~ ^N:[[:space:]]* ]]; then
        name=$(echo "$line" | cut -d'"' -f2)
    elif [[ $line =~ ^P:[[:space:]]* ]]; then
        phys=$(echo "$line" | cut -d'"' -f2)
    elif [[ $line =~ ^U:[[:space:]]* ]]; then
        uniq=$(echo "$line" | cut -d'"' -f2)
        printf "%-12s %-30s %-20s %-20s %s\n" "$dev" "${name:0:28}" "${phys:0:18}" "${uniq:0:18}" "$handler" >> "$LOG"
    fi
done < /proc/bus/input/devices

echo "[$(date)] Готово." >> "$LOG"
echo "✅ Лог: $LOG"
