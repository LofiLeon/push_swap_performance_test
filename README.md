# push_swap_performance_test
A bash script in order to test the performance of the 42 project push_swap

**Installation**

Clone this repository into your push_swap folder and cd into it.

```
git clone git@github.com:Roibos22/push_swap_performance_test.git
cd push_swap_performance_test
```

**Usage**
```
./performance.sh [count_of_numbers > 1] [number_of_times > 0]
```
- **count_of_numbers:** count of random numbers to generate for each run.
- **number_of_times** is the number of times to run the test.

**Example**

![Performance Tester Screenshot](https://github.com/Roibos22/push_swap_performance_test/blob/main/performance_tester_screenshot.png)

**Features**

- Supports Linux and Mac OSX systems.
- Generates both positive and negative random numbers.
- Captures and analyses the output of the sorting algorithm, including the number of moves taken to sort the numbers.
- Checks if the sorting algorithm has correctly sorted the numbers.
- Calculates and outputs the average, median, highest, and lowest number of moves across all runs.
- Calculates and outputs a score representing the ratio of successful runs to total runs.

**Requirements**

The checker_linux and checker_Mac executables must be in the same directory as the script.
The push_swap executable must be in the parent directory of the script.

**Limitations**

The script assumes that the sorting algorithm outputs the number of moves taken to sort the numbers.
The script requires bc to calculate averages and scores.
The script does not handle errors in the sorting algorithm other than by reporting them.
