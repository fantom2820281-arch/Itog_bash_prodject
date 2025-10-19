#!/bin/bash

# скрипт покажет процессы пользователя, чтобы отслеживать все процессы
# необходимы права root используйте sudo

GROUP="$1"
if [[ ! "$GROUP" =~ ^(main|resources|files|system)$ ]]; then
    echo "Использование: $0 <main|resources|files|system>"
    exit 1
fi

LOG_FILE="proc_new_${GROUP}_$(date +%Y%m%d_%H%M%S).log"
CACHE_FILE="/tmp/proc_last_pids"

START_TIME=$(date)
echo "[$START_TIME] Скрипт запущен. Группа: $GROUP" > "$LOG_FILE"

CURRENT_PIDS=()
for entry in /proc/*; do
    pid=$(basename "$entry")
    if [[ "$pid" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then
        CURRENT_PIDS+=("$pid")
    fi
done

if [ -f "$CACHE_FILE" ]; then
    mapfile -t LAST_PIDS < "$CACHE_FILE"
else
    LAST_PIDS=()
fi

declare -A LAST_MAP
for p in "${LAST_PIDS[@]}"; do LAST_MAP["$p"]=1; done

case "$GROUP" in
    main)      COLS=("PID" "Name" "cmdline" "cwd" "environ_vars") ;;
    resources) COLS=("PID" "Name" "max_procs" "mounts" "fd_count") ;;
    files)     COLS=("PID" "cmdline" "environ_vars" "root" "fdinfo_count") ;;
    system)    COLS=("PID" "Name" "cwd" "root" "fd_count") ;;
esac

printf -v header "%-8s %-20s %-30s %-30s %-15s" "${COLS[@]}"
echo "$header" >> "$LOG_FILE"
echo "${header//?/-}" >> "$LOG_FILE"

NEW_FOUND=0

for pid in "${CURRENT_PIDS[@]}"; do
    if [ -z "${LAST_MAP[$pid]}" ]; then
            entry="/proc/$pid"
        name=$(grep -m1 "^Name:" "$entry/status" 2>/dev/null | cut -f2)
        cmdline=$(tr '\0' ' ' < "$entry/cmdline" 2>/dev/null | sed 's/ $//' | cut -c1-28)
        cwd=$(readlink "$entry/cwd" 2>/dev/null | cut -c1-28)
        root=$(readlink "$entry/root" 2>/dev/null | cut -c1-28)
        environ_vars=$(tr '\0' '\n' < "$entry/environ" 2>/dev/null | wc -l)
        max_procs=$(grep -m1 "Max processes" "$entry/limits" 2>/dev/null | awk '{print $4}')
        mounts=$(wc -l < "$entry/mounts" 2>/dev/null)
        fd_count=$(ls -1 "$entry/fd" 2>/dev/null | wc -l)
        fdinfo_count=$(ls -1 "$entry/fdinfo" 2>/dev/null | wc -l)

        case "$GROUP" in
            main)
                printf "%-8s %-20s %-30s %-30s %-15s\n" "$pid" "$name" "$cmdline" "$cwd" "$environ_vars" >> "$LOG_FILE"
                ;;
            resources)
                printf "%-8s %-20s %-30s %-30s %-15s\n" "$pid" "$name" "$max_procs" "$mounts" "$fd_count" >> "$LOG_FILE"
                ;;
            files)
                printf "%-8s %-20s %-30s %-30s %-15s\n" "$pid" "$cmdline" "$environ_vars" "$root" "$fdinfo_count" >> "$LOG_FILE"
                ;;
            system)
                printf "%-8s %-20s %-30s %-30s %-15s\n" "$pid" "$name" "$cwd" "$root" "$fd_count" >> "$LOG_FILE"
                ;;
        esac
        NEW_FOUND=1
    fi
done

if [ "$NEW_FOUND" -eq 0 ]; then
    echo "(Новых процессов не обнаружено)" >> "$LOG_FILE"
fi

printf '%s\n' "${CURRENT_PIDS[@]}" > "$CACHE_FILE"

END_TIME=$(date)
echo "" >> "$LOG_FILE"
echo "[$END_TIME] Скрипт завершён. Новые процессы записаны." >> "$LOG_FILE"

echo "✅ Лог: $LOG_FILE"
