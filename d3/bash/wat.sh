#!/bin/bash

sum=0
dontencountered=false

 while read -r line; do
    if [ "$line" = "do()" ]; then
        dontencountered=false
        continue
    fi
    if [[ "$line" = "don't()" ]]; then
        dontencountered=true
        continue
    fi
    if $dontencountered; then
        continue
    fi
    numbers=$(echo "$line" | sed -E 's/mul\(([0-9]+),([0-9]+)\)/\1 \2/')
    read -r num1 num2 <<< "$numbers"
    product=$(echo "$num1 * $num2" | bc)
    export sum=$(echo "$sum + $product" | bc)
done < <(echo "$(grep -oE "mul\([0-9]+\s*,\s*[0-9]+\)|do\(\)|don\'t\(\)" input)" | tr ' ' '\n')

echo $sum