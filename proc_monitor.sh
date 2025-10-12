#!/bin/bash

GROUP="$1"
LOG_FILE="proc_table_${GROUP}_$(date +%Y%m%d_%H%M%S).log"

if [[ ! "$GROUP" =~ ^(main|resources|files|system)$ ]]; then
    echo "Использование: $0 <main|resources|files|system>"
    exit 1
fi

# Определяем заголовки по группе
case "$GROUP" in
    main)      COLS=("PID" "Name" "cmdline" "cwd" "environ_vars") ;;
    resources) COLS=("PID" "Name" "max_procs" "mounts" "fd_count") ;;
    files)     COLS=("PID" "cmdline" "environ_vars" "root" "fdinfo_count") ;;
    system)    COLS=("PID" "Name" "cwd" "root" "fd_count") ;;
esac

# Функция для выравнивания (простая, без внешних утилит)
printf -v header "%-8s %-20s %-30s %-30s %-15s" "${COLS[@]}"
echo "$header" > "$LOG_FILE"
echo "${header//?/-}" >> "$LOG_FILE"

for entry in /proc/*; do
    pid=$(basename "$entry")
    if [[ "$pid" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then

        # Извлечение данных
        name=$(grep -m1 "^Name:" "$entry/status" 2>/dev/null | cut -f2)
        cmdline=$(tr '\0' ' ' < "$entry/cmdline" 2>/dev/null | sed 's/ $//' | cut -c1-28)
        cwd=$(readlink "$entry/cwd" 2>/dev/null | cut -c1-28)
        root=$(readlink "$entry/root" 2>/dev/null | cut -c1-28)
        environ_vars=$(tr '\0' '\n' < "$entry/environ" 2>/dev/null | wc -l)
        max_procs=$(grep -m1 "Max processes" "$entry/limits" 2>/dev/null | awk '{print $4}')
        mounts=$(wc -l < "$entry/mounts" 2>/dev/null)
        fd_count=$(ls -1 "$entry/fd" 2>/dev/null | wc -l)
        fdinfo_count=$(ls -1 "$entry/fdinfo" 2>/dev/null | wc -l)

        # Формирование строки по группе
        case "$GROUP" in
            main)
                printf "%-8s %-20s %-30s %-30s %-15s\n" \
                    "$pid" "$name" "$cmdline" "$cwd" "$environ_vars" >> "$LOG_FILE"
                ;;
            resources)
                printf "%-8s %-20s %-30s %-30s %-15s\n" \
                    "$pid" "$name" "$max_procs" "$mounts" "$fd_count" >> "$LOG_FILE"
                ;;
            files)
                printf "%-8s %-20s %-30s %-30s %-15s\n" \
                    "$pid" "$cmdline" "$environ_vars" "$root" "$fdinfo_count" >> "$LOG_FILE"
                ;;
            system)
                printf "%-8s %-20s %-30s %-30s %-15s\n" \
                    "$pid" "$name" "$cwd" "$root" "$fd_count" >> "$LOG_FILE"
                ;;
        esac
    fi
done

echo "✅ Таблица сохранена: $LOG_FILE"
