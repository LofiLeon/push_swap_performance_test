#!/bin/bash

# Determine operating system
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    checker_executable="./checker_linux"
elif [[ "$OSTYPE" == "darwin"* ]]; then
    checker_executable="./checker_Mac"
else
    echo "Unsupported operating system. This script supports Linux and Mac OSX."
    exit 1
fi

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Define the number of random numbers (n) and number of times from the arguments (times)
n=$1
times=$2

# Check if the correct number of arguments is provided and if arguments are in correct range
if [ $# -ne 2 -o $n -lt 2 -o $times -lt 1 ]; then
    echo "Usage: $0 [count_of_numbers > 1] [number_of_times > 0]"
    exit 1
fi

# Define output format
output_format_run="Run %-5s | Moves: %-5s | Result: %b\n"
output_format_stats="%-8s: %-5s\n"

# Initialize variables
total_moves=0
correct_runs=0
moves_array=()

echo "----------------------------------------"
# Run the program the specified number of times
for (( i=1; i<=times; i++ ))
do
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
        random_numbers_positive=$(jot -r $(($n / 2)) 1 1000 | tr '\n' ' ' | sed 's/ $//')
        random_numbers_negative=$(jot -r $(($n - $n / 2)) 1 1000 | awk '{print $0*-1}' | tr '\n' ' ' | sed 's/ $//')
        # Combine positive and negative random numbers
        random_numbers="$random_numbers_positive $random_numbers_negative"
        # Convert the string into an array and shuffle it
        read -ra random_numbers_array <<< "$random_numbers"
        random_numbers=$(printf "%s\n" "${random_numbers_array[@]}" | awk 'BEGIN{srand()} {print rand()"\t"$0}' | sort -k1n | cut -f2- | tr '\n' ' ')
    else
        # Linux
        random_numbers_positive=$(shuf -i 1-1000 -n "$(($n / 2))" | tr '\n' ' ' | sed 's/ $//')
        random_numbers_negative=$(shuf -i 1-1000 -n "$(($n - $n / 2))" | awk '{print $0*-1}' | tr '\n' ' ' | sed 's/ $//')
        # Combine positive and negative random numbers
        random_numbers="$random_numbers_positive $random_numbers_negative"
        # Convert the string into an array and shuffle it
        read -ra random_numbers_array <<< "$random_numbers"
        random_numbers=$(printf "%s\n" "${random_numbers_array[@]}" | shuf | tr '\n' ' ')
    fi

    # Run push_swap and capture the output
    push_swap_output=$(.././push_swap $random_numbers)

    # If push_swap_output is empty, set number_of_moves to 0
    # Else, calculate the number of moves
    if [ -z "$push_swap_output" ]
    then
        number_of_moves=0
    else
        number_of_moves=$(echo "$push_swap_output" | grep -c '^.*$')
    fi
    total_moves=$((total_moves + number_of_moves))

    # Store moves in an array for median calculation
    moves_array+=("$number_of_moves")

    # Pass the push_swap output to checker_linux to verify
    # If push_swap_output is empty, call checker directly with an empty echo piped into it
    if [ -z "$push_swap_output" ]
    then
        verification_result=$(echo "" | $checker_executable $random_numbers 2>/dev/null)
    else
        verification_result=$(echo "$push_swap_output" | $checker_executable $random_numbers 2>/dev/null)
    fi

    # Determine the color based on the result
    # Output the results using printf to maintain alignment and add color
    if [ "$verification_result" == "OK" ] || [ -z "$verification_result" -a "$number_of_moves" -eq 0 ]; then
        color=$GREEN
        correct_runs=$((correct_runs + 1))
    else
        color=$RED
        echo "Failed to sort: $random_numbers"
    fi
    printf "$output_format_run" $i "$number_of_moves" "${color}${verification_result:-OK}${NC}"
done

# Calculate average, median, score, highest and lowest
average=$(echo "$total_moves / $times" | bc)
score=$(echo "$correct_runs/$times")

# Calculate median
sorted_moves=($(printf "%d\n" "${moves_array[@]}" | sort -n))
mid_index=$((times/2))

if (( times % 2 == 0 )); then
  median=$(echo "(${sorted_moves[mid_index]} + ${sorted_moves[mid_index-1]}) / 2" | bc)
else
  median=${sorted_moves[mid_index]}
fi

# Calculate highest and lowest
highest=${sorted_moves[${#sorted_moves[@]}-1]}
lowest=${sorted_moves[0]}

# Output the average, median, score, highest and lowest
echo "----------------------------------------"
printf "$output_format_stats" "Average" "$average"
printf "$output_format_stats" "Median" "$median"
printf "$output_format_stats" "Highest" "$highest"
printf "$output_format_stats" "Lowest" "$lowest"
printf "$output_format_stats" "Score" "$score"
echo "----------------------------------------"
