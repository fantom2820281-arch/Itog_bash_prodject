#!/bin/bash

LOG_FILE="proc_pids_$(date +%Y%m%d_%H%M%S).log"
echo "[$(date)] Сканирование /proc..." > "$LOG_FILE"

for entry in /proc/*; do
    pid=$(basename "$entry")
    if [[ "$pid" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then
        if exe_path=$(readlink "$entry/exe" 2>/dev/null); then
            echo "$pid: $exe_path" >> "$LOG_FILE"
        else
            echo "$pid: <не удалось прочитать exe>" >> "$LOG_FILE"
        fi
    fi
done

echo "[$(date)] Создан Лог: $LOG_FILE" >> "$LOG_FILE"
