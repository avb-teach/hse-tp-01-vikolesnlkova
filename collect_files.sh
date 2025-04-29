#!/usr/bin/env bash

set -e  #Остановить выполнение при ошибке

#Справка
show_help() {
    echo "Использование: $0 [--max_depth N] <входная_директория> <выходная_директория>"
    exit 1
}

#Обработка аргументов
max_depth=""
if [ "$1" = "--max_depth" ]; then
    if [ -z "$2" ]; then
        echo "Ошибка: после --max_depth нужно указать число."
        show_help
    fi
    max_depth="$2"
    shift 2
fi

#Остается 2 аргумента
if [ $# -ne 2 ]; then
    echo "Ошибка: нужно указать входную и выходную директории."
    show_help
fi

input_dir="$1"
output_dir="$2"

#Проверка директорий
if [ ! -d "$input_dir" ]; then
    echo "Ошибка: входная директория '$input_dir' не существует."
    exit 1
fi

mkdir -p "$output_dir"

#Команда поиска файлов
if [ -n "$max_depth" ]; then
    find "$input_dir" -maxdepth "$max_depth" -type f > files.txt
else
    find "$input_dir" -type f > files.txt
fi

#Подсчёт общего количества файлов
total_files=$(cat files.txt | wc -l)
copied_files=0

#Проходка по каждому найденному файлу
while read -r file; do
    filename=$(basename "$file")
    destination="$output_dir/$filename"

    #Если файл уже существует
    if [ -f "$destination" ]; then
        i=1

    #Пока файл с таким именем существует, прибавляем номер
        while [ -f "${destination}_$i" ]; do
            i=$((i + 1))
        done

    #Обновляем имя файла с номером
        destination="${destination}_$i"
    fi

    # Копируем файл
    cp "$file" "$destination"
    copied_files=$((copied_files + 1))

done < files.txt


#Выводим результат
echo
echo "Результат:"
echo "Скопировано файлов: $copied_files из $total_files"
if [ -n "$max_depth" ]; then
    echo "Ограничение глубины: $max_depth"
fi
echo "Файлы сохранены в: $output_dir"
