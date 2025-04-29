#!/usr/bin/env bash

#Обработка аргументов
max_depth=""
input_dir="$1"
output_dir="$2"
#if [ "$3" = "--max_depth" ]; then
#    max_depth="$4"
#fi
mkdir -p "$output_dir"
#Команда поиска файлов
if [ -n "$max_depth" ]; then
    find "$input_dir" -maxdepth "$max_depth" -type f > files
else
    find "$input_dir" -type f > files
fi

#Подсчёт общего количества файлов
total_files=$(cat files | wc -l)
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