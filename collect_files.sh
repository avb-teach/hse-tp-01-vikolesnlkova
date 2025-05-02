#!/usr/bin/env bash
set -e

show_help() {
    echo "Usage: $0 [--max_depth N] <input_dir> <output_dir>"
    exit 1
}

# Defaults
max_depth=""
args=()

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --max_depth)
            if [[ -z "$2" || "$2" =~ ^- ]]; then
                echo "Error: --max_depth requires a number"
                show_help
            fi
            max_depth="$2"
            shift 2
            ;;
        -*)
            echo "Unknown option: $1"
            show_help
            ;;
        *)
            args+=("$1")
            shift
            ;;
    esac
done

# Require input and output dir
if [[ ${#args[@]} -ne 2 ]]; then
    echo "Error: Must provide input and output directories"
    show_help
fi

input_dir="${args[0]}"
output_dir="${args[1]}"

# Check input dir
if [[ ! -d "$input_dir" ]]; then
    echo "Error: Input directory '$input_dir' does not exist"
    exit 1
fi

mkdir -p "$output_dir"

# File finding
files=$(mktemp)
trap 'rm -f "$files"' EXIT

if [[ -n "$max_depth" ]]; then
    find "$input_dir" -type f -maxdepth "$max_depth" > "$files"
else
    find "$input_dir" -type f > "$files"
fi

# Copying files
copied=0
while IFS= read -r file; do
    name=$(basename "$file")
    dest="$output_dir/$name"

    if [[ -e "$dest" ]]; then
        base="${name%.*}"
        ext="${name##*.}"
        i=1
        while [[ -e "$output_dir/${base}_$i.$ext" ]]; do
            i=$((i + 1))
        done
        dest="$output_dir/${base}_$i.$ext"
    fi

    cp "$file" "$dest"
    copied=$((copied + 1))
done < "$files"

# Output
echo "Copied $copied files to $output_dir"
[[ -n "$max_depth" ]] && echo "Max depth: $max_depth"