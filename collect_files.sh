#!/usr/bin/env bash

#Обработка аргументов
input_dir="$1"
output_dir="$2"

mkdir -p "$output_dir"

find "$input_dir" -type f > files

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
