#!/usr/bin/env bash

set -e  # Остановить выполнение при ошибке

# Справка
show_help() {
    echo "Использование: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
}

# Обработка аргументов
max_depth=""
if [ "$1" = "--max_depth" ]; then
    if [ -z "$2" ]; then
        echo "Ошибка: после --max_depth нужно указать число."
        show_help
    fi
    max_depth="$2"
    shift 2
fi

# Проверка оставшихся аргументов
if [ $# -ne 2 ]; then
    echo "Ошибка: нужно указать входную и выходную директории."
    show_help
fi

input_dir="$1"
output_dir="$2"

# Проверка входной директории
if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"

# Корректировка глубины (тест ожидает 1 = поддиректории, find считает 0 как текущий)
if [ -n "$max_depth" ]; then
    find_depth=$((max_depth + 1))
    find "$input_dir" -maxdepth "$find_depth" -type f > files.txt
else
    find "$input_dir" -type f > files.txt
fi

total_files=$(wc -l < files.txt)
copied_files=0

while read -r file; do
    filename=$(basename "$file")
    base="${filename%.*}"
    ext="${filename##*.}"

    # Обработка случаев без расширения
    if [ "$base" = "$filename" ]; then
        ext=""
    else
        ext=".$ext"
    fi

    destination="$output_dir/$base$ext"

    if [ -e "$destination" ]; then
        i=1
        while [ -e "$output_dir/${base}_$i$ext" ]; do
            i=$((i + 1))
        done
        destination="$output_dir/${base}_$i$ext"
    fi

    cp "$file" "$destination"
    copied_files=$((copied_files + 1))
done < files.txt

rm -f files.txt

# Вывод
echo "Скопировано файлов: $copied_files из $total_files"
if [ -n "$max_depth" ]; then
    echo "Ограничение глубины: $max_depth"
fi
echo "Файлы сохранены в: $output_dir"
