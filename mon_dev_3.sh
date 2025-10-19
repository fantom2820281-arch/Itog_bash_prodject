#!/bin/bash

LOG="input_new_$(date +%Y%m%d_%H%M%S).log"
CACHE="/tmp/input_devices_cache"

START=$(date)
echo "[$START] Скрипт запущен. Поиск новых устройств..." > "$LOG"

if [ ! -f /proc/bus/input/devices ]; then
    echo "❌ /proc/bus/input/devices недоступен" >> "$LOG"
    exit 1
fi

CURRENT=()
while IFS= read -r line; do
    if [[ $line =~ ^N:[[:space:]]* ]]; then
        name=$(echo "$line" | cut -d'"' -f2)
    elif [[ $line =~ ^P:[[:space:]]* ]]; then
        phys=$(echo "$line" | cut -d'"' -f2)
        CURRENT+=("$name|$phys")
    fi
done < /proc/bus/input/devices

if [ -f "$CACHE" ]; then
    mapfile -t LAST < "$CACHE"
else
    LAST=()
fi

declare -A LAST_MAP
for dev in "${LAST[@]}"; do
    LAST_MAP["$dev"]=1
done

{
    printf "%-30s %s\n" "NAME" "PHYS"
    echo "----------------------------------------------------------------"
} >> "$LOG"

NEW_FOUND=0

for dev in "${CURRENT[@]}"; do
    if [ -z "${LAST_MAP[$dev]}" ]; then
        name=$(echo "$dev" | cut -d'|' -f1)
        phys=$(echo "$dev" | cut -d'|' -f2)
        printf "%-30s %s\n" "${name:0:28}" "$phys" >> "$LOG"
        NEW_FOUND=1
    fi
done

if [ "$NEW_FOUND" -eq 0 ]; then
    echo "(Новых устройств не обнаружено)" >> "$LOG"
fi

printf '%s\n' "${CURRENT[@]}" > "$CACHE"

END=$(date)
echo "" >> "$LOG"
echo "[$END] Скрипт завершён." >> "$LOG"

echo "✅ Лог: $LOG"
