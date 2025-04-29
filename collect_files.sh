#!/bin/bash

show_help() {
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
}

# Аргументы
max_depth=""
if [ "$1" = "--max_depth" ]; then
    if [ -z "$2" ]; then
        echo "Error: --max_depth requires a number."
        show_help
    fi
    max_depth="$2"
    shift 2
fi

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

# Поиск файлов
temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT

if [ -n "$max_depth" ]; then
    find "$input_dir" -maxdepth "$max_depth" -type f -print0 > "$temp_file"
else
    find "$input_dir" -type f -print0 > "$temp_file"
fi

copied_files=0
total_files=$(tr -cd '\0' < "$temp_file" | wc -c)

# Копирование файлов
while IFS= read -r -d '' file; do
    # Относительный путь от входной директории
    rel_path="${file#$input_dir/}"
    dest_path="$output_dir/$rel_path"
    dest_dir=$(dirname "$dest_path")

    mkdir -p "$dest_dir"

    base_name=$(basename "$rel_path")
    name="${base_name%.*}"
    ext="${base_name##*.}"

    if [ "$name" = "$base_name" ]; then
        ext=""
    fi

    final_dest="$dest_path"
    if [ -f "$final_dest" ]; then
        i=1
        while true; do
            if [ -n "$ext" ]; then
                final_dest="${dest_dir}/${name}_$i.$ext"
            else
                final_dest="${dest_dir}/${name}_$i"
            fi
            [ ! -f "$final_dest" ] && break
            i=$((i + 1))
        done
    fi

    cp "$file" "$final_dest"
    copied_files=$((copied_files + 1))
done < "$temp_file"

# Результат
echo "Скопировано файлов: $copied_files из $total_files"
[ -n "$max_depth" ] && echo "Ограничение глубины: $max_depth"
echo "Файлы сохранены в: $output_dir" ]