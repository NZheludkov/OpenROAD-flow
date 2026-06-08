#!/bin/bash
# merge_run_info.sh – объединение всех run_info.csv в один CSV (без дополнительных колонок)
# Использование: ./merge_run_info.sh [корневая_директория] [выходной_файл]
# По умолчанию: корень = /home/nvgel/phd/dataset, выход = merged_stats.csv

set -e

# ------------------- параметры -------------------
ROOT_DIR="${1:-/home/nvgel/phd/dataset}"
OUTPUT_FILE="${2:-merged_stats.csv}"

# ------------------- проверки -------------------
if [ ! -d "$ROOT_DIR" ]; then
    echo "Ошибка: директория '$ROOT_DIR' не существует."
    exit 1
fi

# ------------------- сбор файлов -------------------
echo "Поиск run_info.csv в $ROOT_DIR ..."
mapfile -t csv_files < <(find "$ROOT_DIR" -type f -name "run_info.csv" | sort)

if [ ${#csv_files[@]} -eq 0 ]; then
    echo "Не найдено ни одного run_info.csv"
    exit 0
fi

echo "Найдено файлов: ${#csv_files[@]}"

# ------------------- обработка -------------------
first_file=true

for file in "${csv_files[@]}"; do
    if $first_file; then
        # Первый файл: берём заголовок и все строки (но можно только первую строку как заголовок)
        cat "$file" > "$OUTPUT_FILE"
        first_file=false
    else
        # Остальные файлы: пропускаем первую строку (заголовок), дописываем остальное
        tail -n +2 "$file" >> "$OUTPUT_FILE"
    fi
done

echo "Готово. Результат записан в $OUTPUT_FILE"