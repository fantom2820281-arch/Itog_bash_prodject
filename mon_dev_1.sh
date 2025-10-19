#!/bin/bash

LOG="input_devices_$(date +%Y%m%d_%H%M%S).log"

echo "[$(date)] Сканирование /proc/bus/input/..." > "$LOG"

if [ -d /proc/bus/input ]; then
    ls -l /proc/bus/input/ >> "$LOG" 2>&1
else
    echo "Директория /proc/bus/input отсутствует." >> "$LOG"
fi

echo "[$(date)] Готово. Лог: $LOG"
echo "✅ $LOG"
