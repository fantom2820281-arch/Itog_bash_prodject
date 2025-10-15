# Итоговый проект Bash 

# Герасин Дмитрий Сергеевич
## студент школы натология.

P.S. Уважаемые преподователи я понимаю что вы не обязаны такое читать , вы   
должны открыть и увидеть решенное задание. я его выполню, можете нe отправлять на доработку я этот репозиторий отредактирую, можете отправить на доработку только уточните до какого числа мне необходимо его сдать, я приступлить смогу не ранее 18.10 но за два три дня все сделаю, извините за причиненные неудобства. Вы прекрасно понимаете что BASH до уровня хорошего Администратора за месяц не осилить тем более когда нет возможности заниматься с полным погружением в тему, я пока писать могу простенькте скрипты, все тестовые задания я делал самостоятельно. 


### 1 задание 

1. Задание по созданию Bash-скрипта, который будет выполнять мониторинг содержимого директории proc, получать сведения о процессах и системных данных о них, сбор полученной информации в логе

1.1 Напишите Bash-скрипт, который выполняет просмотр директории /proc и записывает номерные директории.


В данном скрипте мы проверяем только дирректории которые представлены числом,  
номером процесса PID, для реализации данного скрипта задействован цикл for.

#!/bin/bash

LOG_FILE="proc_pids_$(date +%Y%m%d_%H%M%S).log"

echo "[$(date)] Начинаю сканирование /proc..." > "$LOG_FILE"

for entry in /proc/*; do
    dir_name=$(basename "$entry")
    if [[ "$dir_name" =~ ^[0-9]+$ ]] && [ -d "$entry" ]; then
        echo "$dir_name" >> "$LOG_FILE"
    fi
done

echo "[$(date)] Сканирование завершено. Результат сохранён в $LOG_FILE" >> "$LOG_FILE"
echo "✅ Лог создан: $LOG_FILE"

Данный скрипт создает лог файл. 

[Wed Oct 15 11:49:13 AM MSK 2025] Начинаю сканирование /proc...
1
10
100
101
13
14
15
1538
1539


В логфайле номера процессов, перед началом сканирования на экран выводим текст с датой и временем запуска скрипта. 

По окончанию работы скрипта создается файл и помещается в дирректорию где находится скрипт


результат работы скрипта представлен на скриншоте ниже 

![запускаем мониторинг proc](~/probe_git/img/scren_1.1.png)


Проверка чистового завершения пункта 1.1 задания должен быть виден код, результат работы в терминале, и скриншот. 














На сегодня получается вставить скрин 
![proc 1.1](github.com/username/fantom2820281-arch/itog_bash_project/blob/branch/path//'Pasted image.png')  



пробуем вставить скрин, остается вставлять код.

пробуем вставить код
## code
   bash
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
dima@4540s:~/probe_git$ 



## скриншот
![my_first_screnshot](/home/dima/probe_git/Pasted image.png)

делаем коммит и пушим из терминала в vs code получается!!!










 sudo crontab -e
 */5 * * * * /home/dima/probe_git/proc_monitor.sh main >> /var/log/familyhearth_cron.log 2>&1



