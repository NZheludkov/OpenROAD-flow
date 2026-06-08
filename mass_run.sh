#!/bin/bash

# =============================================================================
# mass_run.sh – массовый запуск run_flow.sh с перебором параметров
# =============================================================================

# ---------------------------- значения по умолчанию ----------------------------
pdk_path=""
rtl_dataset_path=""
output_dir=""
designs_file=""
max_parallel=4
verbose=0

# ---------------------------- параметры перебора (жестко в скрипте) ------------
#clk_periods=("10.0" "15.0")          # CLK_PERIOD (2 значения)
#cus=("30" "40")                         # CU (2 значения)
#ars=("0.5" "1.0")                      # AR (2 значения)
#pdn_hpitch_tracks=("32" "64")                # PDN_HPITCH_TRACK (2 значения)
#pdn_vpitch_tracks=("32" "64")                # PDN_VPITCH_TRACK (2 значения)

default_clk_periods=("10.0")          # CLK_PERIOD (2 значения)
cus=("20" "30")                         # CU (2 значения)
ars=("0.5" "1.0")                      # AR (2 значения)
pdn_hpitch_tracks=("32" "64")                # PDN_HPITCH_TRACK (2 значения)
#pdn_vpitch_tracks=("32")                # PDN_VPITCH_TRACK (2 значения)

# ---------------------------- функции ------------------------------------------
show_help() {
    cat << EOF
Использование: $0 [ОПЦИИ]

Обязательные опции:
    --pdk_path PATH              Путь к PDK (например, /home/user/lambdapdk/freepdk45)
    --rtl_dataset_path PATH      Путь к RTL‑датасету
    --output_dir DIR             Базовая директория для сохранения результатов
    --designs_file FILE          Файл со списком имён дизайнов (по одному на строку)

Дополнительные опции:
    --verbose, -v                Подробный вывод
    --help, -h                   Показать эту справку

Пример:
    $0 --pdk_path /home/user/open_pdk/lambdapdk/freepdk45 \\
       --rtl_dataset_path /home/user/RTL-Dataset \\
       --output_dir /home/user/runs \\
       --designs_file design_list.txt
EOF
}


# ---------------------------- парсинг аргументов -------------------------------
while [[ $# -gt 0 ]]; do
    case $1 in
        --pdk_path)            pdk_path="$2"; shift 2 ;;
        --rtl_dataset_path)    rtl_dataset_path="$2"; shift 2 ;;
        --output_dir)          output_dir="$2"; shift 2 ;;
        --designs_file)        designs_file="$2"; shift 2 ;;
        --max_parallel)        max_parallel="$2"; shift 2 ;;        
        --verbose|-v)          verbose=1; shift ;;
        --help|-h)             show_help; exit 0 ;;
        *) echo "Ошибка: Неизвестная опция $1"; show_help; exit 1 ;;
    esac
done

# ---------------------------- проверка обязательных параметров -----------------
if [[ -z "$pdk_path" || -z "$rtl_dataset_path" || -z "$output_dir" || -z "$designs_file" ]]; then
    echo "Ошибка: не все обязательные параметры заданы."
    show_help
    exit 1
fi

if [[ ! -f "$designs_file" ]]; then
    echo "Ошибка: файл со списком дизайнов '$designs_file' не найден."
    exit 1
fi

# ---------------------------- чтение дизайнов с периодами -----------------------
declare -A design_periods   # ассоциативный массив: ключ=имя дизайна, значение=строка с периодами через пробел
designs_order=()            # сохраняем порядок для удобства

while IFS= read -r line; do
    # очистка от лишних пробелов
    line="$(echo "$line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Разбиваем строку на слова
    read -ra words <<< "$line"
    design="${words[0]}"
    # Всё, что после первого слова – это периоды (если есть)
    if [ ${#words[@]} -gt 1 ]; then
        periods="${words[@]:1}"          # строка из всех периодов
    else
        periods=""                       # пусто => использовать глобальный массив
    fi

    designs_order+=("$design")
    design_periods["$design"]="$periods"
done < "$designs_file"

if [ ${#designs_order[@]} -eq 0 ]; then
    echo "Ошибка: список дизайнов пуст."
    exit 1
fi

# ---------------------------- запуск с контролем параллелизма --------------------
active=0
for design in "${designs_order[@]}"; do
    # Определяем список периодов для текущего дизайна
    periods_str="${design_periods[$design]}"
    if [ -n "$periods_str" ]; then
        # Превращаем строку в массив
        read -ra design_clk_periods <<< "$periods_str"
    else
        # Используем глобальный массив по умолчанию
        design_clk_periods=("${default_clk_periods[@]}")
    fi

    # Теперь для каждого периода запускаем перебор остальных параметров
    for clk in "${design_clk_periods[@]}"; do
        for cu in "${cus[@]}"; do
            for ar in "${ars[@]}"; do
                for hpitch in "${pdn_hpitch_tracks[@]}"; do
                        ((active >= max_parallel)) && { wait -n; ((active--)); }
                        ./run_flow.sh \
                            --pdk_path "$pdk_path" \
                            --rtl_dataset_path "$rtl_dataset_path" \
                            --design "$design" \
                            --output_dir "$output_dir" \
                            --clk_period "$clk" \
                            --cu "$cu" \
                            --ar "$ar" \
                            --pdn_hpitch_track "$hpitch" \
                            --pdn_vpitch_track "$hpitch" &
                        ((active++))
                    done
                done
            done
        done
    done
done
wait
echo "Все запуски завершены."