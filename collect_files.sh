#!/bin/bash

show_help() {
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
}

# Обработка аргументов
max_depth=""
while [[ "$1" == --max_depth* ]]; do
    if [[ -z "$2" || ! "$2" =~ ^[0-9]+$ ]]; then
        echo "Error: --max_depth requires a valid number."
        show_help
    fi
    max_depth="$2"
    shift 2
done

if [ $# -ne 2 ]; then
    echo "Error: Must provide input and output directories."
    show_help
fi

input_dir="$1"
output_dir="$2"

if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory '$input_dir' does not exist."
    exit 1
fi

mkdir -p "$output_dir"

# Поиск и копирование файлов
copied_files=0
total_files=0

find "$input_dir" $( [ -n "$max_depth" ] && echo "-maxdepth $max_depth" ) -type f | while IFS= read -r file; do
    # Рассчитываем относительный путь
    rel_path="${file#$input_dir/}"
    dest_path="$output_dir/$rel_path"
    dest_dir=$(dirname "$dest_path")

    mkdir -p "$dest_dir"

    # Обработка уникальности имени файла
    base_name=$(basename "$rel_path")
    name="${base_name%.*}"
    ext="${base_name##*.}"
    
    if [ "$name" = "$base_name" ]; then
        ext=""
    fi

    final_dest="$dest_path"
    i=1
    while [ -f "$final_dest" ]; do
        if [ -n "$ext" ]; then
            final_dest="${dest_dir}/${name}_$i.$ext"
        else
            final_dest="${dest_dir}/${name}_$i"
        fi
        i=$((i + 1))
    done

    # Копирование файла
    cp "$file" "$final_dest"
    copied_files=$((copied_files + 1))
    total_files=$((total_files + 1))
done

# Результат
echo "Скопировано файлов: $copied_files из $total_files"
[ -n "$max_depth" ] && echo "Ограничение глубины: $max_depth"
echo "Файлы сохранены в: $output_dir"
