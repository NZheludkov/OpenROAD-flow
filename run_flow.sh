#!/bin/bash

# Значения по умолчанию
pdk_path=""
rtl_dataset_path=""
design=""
output_dir=""
verbose=0

# Функция для вывода справки
show_help() {
    cat << EOF
Использование: $0 [ОПЦИИ]

Обязательные опции:
    --pdk_path PATH         Путь к PDK
    --rtl_dataset_path PATH Путь к RTL датасету

Дополнительные опции:
    --output_dir PATH       Директория для результатов (по умолчанию: ./output)
    --verbose, -v           Подробный вывод
    --help, -h              Показать эту справку

Пример:
    $0 --pdk_path ./PDK --rtl_dataset_path ./data/dataset
EOF
}

# Парсинг аргументов командной строки
while [[ $# -gt 0 ]]; do
    case $1 in
        --pdk_path)
            pdk_path="$2"
            shift 2
            ;;
        --rtl_dataset_path)
            rtl_dataset_path="$2"
            shift 2
            ;;
         --design)
            design="$2"
            shift 2
            ;;           
        --output_dir)
            output_dir="$2"
            shift 2
            ;;
        --verbose|-v)
            verbose=1
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Ошибка: Неизвестная опция $1"
            echo "Используйте --help для получения справки"
            exit 1
            ;;
    esac
done

# Проверка обязательных параметров
if [[ -z "$pdk_path" ]]; then
    echo "Ошибка: Не указан параметр --pdk_path"
    echo "Используйте --help для получения справки"
    exit 1
fi

if [[ -z "$rtl_dataset_path" ]]; then
    echo "Ошибка: Не указан параметр --rtl_dataset_path"
    echo "Используйте --help для получения справки"
    exit 1
fi

if [[ -z "$design" ]]; then
    echo "Ошибка: Не указан параметр --design"
    echo "Используйте --help для получения справки"
    exit 1
fi

if [[ -z "$output_dir" ]]; then
    echo "Ошибка: Не указан параметр --output_dir"
    echo "Используйте --help для получения справки"
    exit 1
fi

# Создание выходной директории
mkdir -p "$output_dir"

# Вывод информации (если verbose режим)
if [[ $verbose -eq 1 ]]; then
    echo "=== Параметры запуска ==="
    echo "PDK путь: $pdk_path"
    echo "RTL датасет: $rtl_dataset_path"
    echo "Выходная директория: $output_dir"
    echo "========================"
fi

# Здесь ваш основной код
# Например:
#echo "Запуск обработки..."
#echo "Обработка PDK: $PDK_PATH"
#echo "Использование датасета: $RTL_DATASET_PATH"
#echo "Результаты сохраняются в: $OUTPUT_DIR"

#exports vars
export design
export rtl_dataset_path
export pdk_path
export output_dir

yosys ./flow_scripts/run_yosys.tcl

openroad -threads 4 -log ./log.txt \
-metrics metrics.txt \
./flow_scripts/run_openroad.tcl -exit

# Пример реальной работы (раскомментируйте и адаптируйте):
# python3 your_script.py \
#     --pdk "$PDF_PATH" \
#     --dataset "$RTL_DATASET_PATH" \
#     --output "$OUTPUT_DIR"

# Завершение скрипта
echo "Готово!"
exit 0