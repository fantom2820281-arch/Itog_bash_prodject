#!/bin/bash

LOG_FILE="proc_full_$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"
}

log "Начало сбора данных по процессам..."

for entry in /proc/*; do
    pid=$(basename "$entry")
    if [[ "$pid" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then
        log "=== PID: $pid ==="

        # 1. cmdline
        if [ -r "$entry/cmdline" ]; then
            cmdline=$(tr '\0' ' ' < "$entry/cmdline" | sed 's/ $//')
            log "cmdline: $cmdline"
        fi

        # 2. status (имя процесса и основные данные)
        if [ -r "$entry/status" ]; then
            name=$(grep -m1 "^Name:" "$entry/status" 2>/dev/null | cut -f2)
            log "Name: $name"
        fi

        # 3. cwd
        if [ -L "$entry/cwd" ]; then
            cwd=$(readlink "$entry/cwd" 2>/dev/null)
            log "cwd: $cwd"
        fi

        # 4. exe
        if [ -L "$entry/exe" ]; then
            exe=$(readlink "$entry/exe" 2>/dev/null)
            log "exe: $exe"
        fi

        # 5. mounts
        if [ -r "$entry/mounts" ]; then
            mounts=$(wc -l < "$entry/mounts")
            log "mounts: $mounts точек монтирования"
        fi

        # 6. limits
        if [ -r "$entry/limits" ]; then
            nproc=$(grep -m1 "Max processes" "$entry/limits" 2>/dev/null | awk '{print $4}')
            log "Max processes limit: $nproc"
        fi

        log ""
    fi
done

log "Сбор завершён."
echo "✅ Лог: $LOG_FILE"
