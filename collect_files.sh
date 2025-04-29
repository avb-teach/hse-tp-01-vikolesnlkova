#!/usr/bin/env bash

#Обработка аргументов
input_dir="$1"
output_dir="$2"

mkdir -p "$output_dir"
touch files.txt

find "$input_dir" -type f > files.txt