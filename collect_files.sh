#!/usr/bin/env bash
set -e

show_help() {
    echo "Использование: $0 [--max_depth N] <входная_директория> <выходная_директория>"
    exit 1
}

#Инициализация
max_depth=""
input_dir=""
output_dir=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            shift
            max_depth="$1"
            ;;
        -*)
            echo "Неизвестный параметр: $1"
            show_help
            ;;
        *)
            if [ -z "$input_dir" ]; then
                input_dir="$1"
            elif [ -z "$output_dir" ]; then
                output_dir="$1"
            else
                echo "Слишком много позиционных аргументов"
                show_help
            fi
            ;;
    esac
    shift
done

#Проверка обязательных
if [ -z "$input_dir" ] || [ -z "$output_dir" ]; then
    echo "Ошибка: нужно указать входную и выходную директории."
    show_help
fi

if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"

#Временный файл
files=$(mktemp)
trap 'rm -f "$files"' EXIT

#Поиск файлов
if [ -n "$max_depth" ]; then
    find "$input_dir" -maxdepth "$max_depth" -type f > "$files"
else
    find "$input_dir" -type f > "$files"
fi

total_files=$(wc -l < "$files")
copied_files=0

while read -r file; do
    filename=$(basename "$file")
    destination="$output_dir/$filename"

    if [ -f "$destination" ]; then
        base="${filename%.*}"
        ext="${filename##*.}"
        i=1
        while [ -f "${output_dir}/${base}_$i.${ext}" ]; do
            i=$((i + 1))
        done
        destination="${output_dir}/${base}_$i.${ext}"
    fi

    cp "$file" "$destination"
    copied_files=$((copied_files + 1))
done < "$files"

echo "Скопировано файлов: $copied_files из $total_files"
[ -n "$max_depth" ] && echo "Ограничение глубины: $max_depth"
echo "Файлы сохранены в: $output_dir"
