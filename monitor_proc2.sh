#!/bin/bash
# если необходимо запускаем скрипт с арументами
# ./monitor_proc2.sh main
#./monitor_proc2.sh resources
#./monitor_proc2.sh files
#./monitor.sh system

GROUP="$1"
LOG_FILE="proc_${GROUP}_$(date +%Y%m%d_%H%M%S).log"

if [[ ! "$GROUP" =~ ^(main|resources|files|system)$ ]]; then
    echo "Использование: $0 <main|resources|files|system>"
    exit 1
fi

log() {
    echo "[$(date -Iseconds)] $*" >> "$LOG_FILE"
}

log "Сбор группы: $GROUP"

for entry in /proc/*; do
    pid=$(basename "$entry")
    if [[ "$pid" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then
        log "=== PID: $pid ==="

        case "$GROUP" in
            main)
                [ -r "$entry/cmdline" ] && log "cmdline: $(tr '\0' ' ' < "$entry/cmdline" | sed 's/ $//')"
                [ -r "$entry/status" ]  && log "Name: $(grep -m1 "^Name:" "$entry/status" | cut -f2)"
                [ -L "$entry/cwd" ]     && log "cwd: $(readlink "$entry/cwd" 2>/dev/null)"
                [ -r "$entry/environ" ] && log "environ: $(tr '\0' '\n' < "$entry/environ" 2>/dev/null | wc -l) переменных"
                ;;

            resources)
                [ -r "$entry/status" ]  && log "Name: $(grep -m1 "^Name:" "$entry/status" | cut -f2)"
                [ -r "$entry/limits" ]  && log "Max processes: $(grep -m1 "Max processes" "$entry/limits" | awk '{print $4}')"
                [ -r "$entry/mounts" ]  && log "mounts: $(wc -l < "$entry/mounts") точек"
                [ -d "$entry/fd" ]      && log "fd: $(ls -1 "$entry/fd" 2>/dev/null | wc -l) дескрипторов"
                ;;

            files)
                [ -r "$entry/cmdline" ]   && log "cmdline: $(tr '\0' ' ' < "$entry/cmdline" | sed 's/ $//')"
                [ -r "$entry/environ" ]   && log "environ: $(tr '\0' '\n' < "$entry/environ" 2>/dev/null | wc -l) переменных"
                [ -L "$entry/root" ]      && log "root: $(readlink "$entry/root" 2>/dev/null)"
                [ -d "$entry/fdinfo" ]    && log "fdinfo: $(ls -1 "$entry/fdinfo" 2>/dev/null | wc -l) записей"
                ;;

            system)
                [ -r "$entry/status" ]  && log "Name: $(grep -m1 "^Name:" "$entry/status" | cut -f2)"
                [ -L "$entry/cwd" ]     && log "cwd: $(readlink "$entry/cwd" 2>/dev/null)"
                [ -L "$entry/root" ]    && log "root: $(readlink "$entry/root" 2>/dev/null)"
                [ -d "$entry/fd" ]      && log "fd: $(ls -1 "$entry/fd" 2>/dev/null | wc -l) дескрипторов"
                ;;
        esac

        log ""
    fi
done

log "Готово."
echo "✅ Лог: $LOG_FILE"
