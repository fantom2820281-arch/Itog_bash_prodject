#!/bin/bash

# Задание 1.1: Мониторинг /proc — сбор PID-директорий
LOG_FILE="proc_pids_$(date +%Y%m%d_%H%M%S).log"

echo "[$(date)] Начинаю сканирование /proc..." > "$LOG_FILE"

# Ищем только директории, название которых — число (PID)
for entry in /proc/*; do
    dir_name=$(basename "$entry")
    if [[ "$dir_name" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then
        echo "$dir_name" >> "$LOG_FILE"
    fi
done

echo "[$(date)] Сканирование завершено. Результат сохранён в $LOG_FILE" >> "$LOG_FILE"
echo "✅ Лог создан: $LOG_FILE"
