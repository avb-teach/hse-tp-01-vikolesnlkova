#!/usr/bin/env bash
set -e 

show_help() {
    echo "Использование: $0 [--max_depth N] <входная_директория> <выходная_директория>"
    exit 1
}

max_depth=""
args=()

while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            if [ -z "$2" ]; then
                echo "Ошибка: после --max_depth нужно указать число."
                show_help
            fi
            max_depth="$2"
            shift 2
            ;;
        -*)
            echo "Неизвестный флаг: $1"
            show_help
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done


if [ ${#args[@]} -ne 2 ]; then
    echo "Ошибка: нужно указать входную и выходную директории."
    show_help
fi

input_dir="${args[0]}"
output_dir="${args[1]}"


if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"


if [ -n "$max_depth" ]; then
    max_depth=$((max_depth + 1))
fi


files=$(mktemp)
trap 'rm -f "$files"' EXIT

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
        name="${filename%.*}"
        ext="${filename##*.}"
        i=1
        while [ -f "$output_dir/${name}_$i.$ext" ]; do
            i=$((i + 1))
        done
        destination="$output_dir/${name}_$i.$ext"
    fi

    cp "$file" "$destination"
    copied_files=$((copied_files + 1))
done < "$files"


echo "Скопировано файлов: $copied_files из $total_files"
[ -n "$max_depth" ] && echo "Ограничение глубины: $((max_depth - 1))"
echo "Файлы сохранены в: $output_dir"
