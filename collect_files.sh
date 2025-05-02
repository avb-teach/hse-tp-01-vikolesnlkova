#!/usr/bin/env bash

set -e  # Остановить выполнение при ошибке

show_help() {
    echo "Использование: $0 [--max_depth N] <входная_директория> <выходная_директория>"
    exit 1
}

# Проверка является ли строка положительным целым числом
is_positive_integer() {
    [[ "$1" =~ ^[1-9][0-9]*$ ]]
}

# Обработка аргументов командной строки
max_depth=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            if [[ $# -lt 2 ]] || ! is_positive_integer "$2"; then
                echo "Ошибка: --max_depth требует положительное целое число" >&2
                show_help
            fi
            max_depth="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            ;;
        -*)
            echo "Неизвестная опция: $1" >&2
            show_help
            ;;
        *)
            break
            ;;
    esac
done

# Проверка оставшихся аргументов
if [[ $# -ne 2 ]]; then
    echo "Ошибка: требуется указать входную и выходную директории" >&2
    show_help
fi

input_dir="$1"
output_dir="$2"

# Проверка существования входной директории
if [[ ! -d "$input_dir" ]]; then
    echo "Ошибка: входная директория '$input_dir' не существует" >&2
    exit 1
fi

# Создание выходной директории
mkdir -p "$output_dir"

# Временный файл для списка файлов
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

# Поиск файлов с учетом max_depth
if [[ -n "$max_depth" ]]; then
    if ! find "$input_dir" -maxdepth "$max_depth" -type f > "$temp_file"; then
        echo "Ошибка при поиске файлов" >&2
        exit 1
    fi
else
    if ! find "$input_dir" -type f > "$temp_file"; then
        echo "Ошибка при поиске файлов" >&2
        exit 1
    fi
fi

# Подсчет файлов
total_files=$(wc -l < "$temp_file" | tr -d ' ')
copied_files=0

# Копирование файлов
while IFS= read -r file; do
    filename=$(basename -- "$file")
    destination="$output_dir/$filename"

    # Обработка дубликатов
    if [[ -e "$destination" ]]; then
        i=1
        while [[ -e "${destination}.${i}" ]]; do
            ((i++))
        done
        destination="${destination}.${i}"
    fi

    if cp -- "$file" "$destination"; then
        ((copied_files++))
    else
        echo "Ошибка при копировании $file" >&2
    fi
done < "$temp_file"

# Вывод результатов
echo
echo "Результат:"
echo "Скопировано файлов: $copied_files из $total_files"
[[ -n "$max_depth" ]] && echo "Ограничение глубины: $max_depth"
echo "Файлы сохранены в: $output_dir"