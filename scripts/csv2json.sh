#!/bin/bash

# csv2json.sh
# Converts a CSV file to a formatted JSON array using python3.
# Usage: ./csv2json.sh <input.csv> [output.json]

if [ -z "$1" ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 <input.csv> [output.json]"
    echo "Converts CSV to JSON and prints to stdout or an output file."
    echo "Example: $0 charts.csv charts.json"
    exit 1
fi

INPUT_CSV="$1"
OUTPUT_JSON="$2"

if [ ! -f "$INPUT_CSV" ]; then
    echo "Error: File '$INPUT_CSV' not found."
    exit 1
fi

PYTHON_SCRIPT=$(cat << 'EOF'
import csv
import json
import sys

def convert_value(val):
    if val is None:
        return ""
    
    val_str = str(val).strip()
    
    # Try converting to integer
    if val_str.isdigit() or (val_str.startswith("-") and val_str[1:].isdigit()):
        return int(val_str)
        
    # Try converting to float
    try:
        if "." in val_str:
            return float(val_str)
    except ValueError:
        pass
        
    return val

try:
    with open(sys.argv[1], "r", encoding="utf-8-sig") as csv_file:
        reader = csv.DictReader(csv_file)
        result = []
        for row in reader:
            parsed_row = {}
            for k, v in row.items():
                if k is not None:
                    parsed_row[str(k).strip()] = convert_value(v)
            result.append(parsed_row)
            
    if len(sys.argv) > 2 and sys.argv[2]:
        with open(sys.argv[2], "w", encoding="utf-8") as json_file:
            json.dump(result, json_file, indent=4)
        print(f"Successfully converted {sys.argv[1]} to {sys.argv[2]}")
    else:
        print(json.dumps(result, indent=4))
        
except Exception as e:
    sys.stderr.write(f"Error processing CSV: {e}\n")
    sys.exit(1)
EOF
)

python3 -c "$PYTHON_SCRIPT" "$INPUT_CSV" "$OUTPUT_JSON"
