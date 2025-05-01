#!/usr/bin/env bash
set -e 

show_help() {
    echo "Использование: $0 [--max_depth N] <входная_директория> <выходная_директория>"
    exit 1
}

#Проверка и обработка флага --max_depth
max_depth=""
if [ "$1" = "--max_depth" ]; then
    if [ -z "$2" ]; then
        echo "Ошибка: укажите число после --max_depth"
        show_help
    fi
    max_depth="$2"
    shift 2
fi

#Теперь должно остаться 2 аргумента
if [ $# -ne 2 ]; then
    echo "Ошибка: нужно указать входную и выходную директории."
    show_help
fi

input_dir="$1"
output_dir="$2"

#Проверяем, что входная директория существует
if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория '$input_dir' не найдена."
    exit 1
fi

#Создаём выходную директорию(ну если нет)
mkdir -p "$output_dir"

#Готовим список файлов
if [ -n "$max_depth" ]; then
    #Увеличиваем глубину на 1
    find "$input_dir" -maxdepth $((max_depth + 1)) -type f > files.txt
else
    find "$input_dir" -type f > files.txt
fi

#Считаем количество файлов
total_files=$(wc -l < files.txt)
copied_files=0

#Копируем каждый файл
while read -r file; do
    name=$(basename "$file")
    target="$output_dir/$name"

    #Если файл с таким именем уже существует, добавим номер
    if [ -f "$target" ]; then
        i=1
        base="${name%.*}"
        ext="${name##*.}"

        while [ -f "$output_dir/${base}_$i.$ext" ]; do
            i=$((i + 1))
        done

        target="$output_dir/${base}_$i.$ext"
    fi

    cp "$file" "$target"
    copied_files=$((copied_files + 1))
done < files.txt

#Показываем результат
echo "Скопировано файлов: $copied_files из $total_files"
if [ -n "$max_depth" ]; then
    echo "Ограничение глубины: $max_depth"
fi
echo "Файлы сохранены в: $output_dir"

