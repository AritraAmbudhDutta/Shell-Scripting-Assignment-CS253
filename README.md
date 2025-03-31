# Shell Scripting Assignment

This repository contains two bash scripts that demonstrate shell scripting capabilities with common Unix tools like `grep`, `sed`, and `awk`.

## 1. Log Analyzer (main.sh)

The `main.sh` script processes CSV log files to extract various statistics about HTTP requests.

### Features:

- Extracts unique IP addresses from logs
- Identifies the top 3 HTTP methods used (GET, POST, etc.)
- Calculates hourly request distribution (0-23 hours)
- Logs execution timestamps for auditing purposes

### Usage:

```bash
bash main.sh logs.csv output1.txt log_ts.txt
```

Where:

- `logs.csv` - Input CSV file containing HTTP request logs
- `output1.txt` - The output file where results will be saved
- `log_ts.txt` - File where execution timestamps will be logged

### Sample Execution:

```bash
$ bash main.sh logs.csv output1.txt log_ts.txt
Processing complete. Results saved to output1.txt
Execution timestamps logged to log_ts.txt
```

## 2. Common Prefix Calculator (larger.sh)

The `larger.sh` script compares two text files line by line and calculates the length of common prefixes between corresponding lines.

### Features:

- Processes files line by line to find common prefix lengths
- Handles cases where one file may have more lines than the other
- Provides detailed output with comments explaining each match
- Uses two different implementations (temporary file method and direct awk method)

### Usage:

```bash
bash larger.sh file1.txt file2.txt
```

Where:

- `file1.txt` - First text file to compare
- `file2.txt` - Second text file to compare

### Sample Execution:

```bash
$ bash larger.sh file1.txt file2.txt
Comparison complete. Results saved to output.txt
File 1: file1.txt
File 2: file2.txt
```

## File Structure

```
.
├── file1.txt          # Sample input file for larger.sh
├── file2.txt          # Sample input file for larger.sh
├── larger.sh          # Common Prefix Calculator script
├── log_ts.txt         # Log timestamps from main.sh execution
├── logs.csv           # Sample log file for main.sh
├── main.sh            # Log Analyzer script
├── output.txt         # Output from larger.sh script
├── output1.txt        # Output from main.sh script
└── README.md          # This file
```

## Example Outputs

### main.sh output (output1.txt):

```
Unique IP addresses:
192.168.1.1
192.168.1.111
192.168.1.112
192.168.1.2
192.168.1.3
192.168.1.4
192.168.1.5
192.168.1.6
192.168.1.7

Top 3 HTTP methods:
GET: 4
DELETE: 3
POST: 2

Requests per hour:
Hour 0: 0 requests
Hour 1: 0 requests
...
Hour 10: 2 requests
...
Hour 23: 1 requests
```

### larger.sh output (output.txt):

```
2 # Common prefix of 'apple' and 'apricot' is 'ap'
3 # Common prefix of 'banana' and 'banter' is 'ban'
2 # Common prefix of 'cherry' and 'chocolate' is 'ch'
4 # Common prefix of 'computer' and 'compatibility' is 'comp'
4 # Common prefix of 'test' and 'testing' is 'test'
0 # Common prefix of 'operation' and 'concentrate' is none
5 # Common prefix of 'messi' and 'messiah' is 'messi'
3 # Common prefix of 'IITB' and 'IITK' is 'IIT'
0 # Common prefix of '' and 'Dhoni' is none
```

## Implementation Details

Both scripts showcase various shell scripting techniques:

1. Command line argument parsing and validation
2. File I/O operations
3. Custom functions
4. Regular expressions with `sed` and `grep`
5. Advanced text processing with `awk`
6. Array usage
7. Loop constructs
8. Conditional logic
9. Error handling
10. Proper logging

## Requirements

- Bash shell (version 4.0 or later recommended)
- Standard Unix tools: `grep`, `sed`, `awk`, `sort`, `uniq`, etc.

## Conclusion

This program was developed by **Aritra Ambudh Dutta (Roll No. 230191)** as part of CS253 Course Programming Assignment offered in Semester 2024-25/II at IIT Kanpur.
