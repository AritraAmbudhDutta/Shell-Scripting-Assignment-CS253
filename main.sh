#!/bin/bash
# =============================================================================
# Assignment 2 - Shell Scripting, CS253 IIT Kanpur
# =============================================================================
# Script Name: main.sh
# Description: Log Analyzer - Processes CSV log files to extract statistics
# Author: Aritra Ambudh Dutta 
# Roll No.: 230191
# Date: March 27, 2025
# =============================================================================
# 
# Purpose:
# This script analyzes a structured log file (CSV format) to extract key metrics
# including unique IP addresses, HTTP method usage statistics, and hourly request
# distribution. All operations are logged with timestamps for auditing purposes.
#
# Input:
#   - logs.csv: A CSV file containing HTTP request logs with the format:
#     IP,timestamp,HTTP_method,request_path,status_code,content_length
#
# Output:
#   - output file: Contains analysis results (IPs, methods, hourly breakdowns)
#   - log timestamp file: Timestamps of script execution steps for auditing
#
# Usage: bash main.sh logs.csv output1.txt log_ts.txt
# =============================================================================

# =============================================================================
# Function Definitions
# =============================================================================

# Function: log_timestamp
# Purpose: Appends a timestamped message to the specified log file
# Parameters:
#   $1 - Message to log
# Example: log_timestamp "Process started"
log_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$log_file"
}

# Function: usage
# Purpose: Displays script usage information and exits
# Parameters: None
# Exit Status: 1 (Error/Invalid Usage)
usage() {
    echo "Usage: $0 input_file output_file log_timestamp_file"
    echo "This script processes a log file and generates statistics."
    echo
    echo "Arguments:"
    echo "  input_file           - Path to the CSV log file (e.g., logs.csv)"
    echo "  output_file          - Path to the file where results will be saved"
    echo "  log_timestamp_file   - Path to the file where execution timestamps will be stored"
    exit 1
}

# =============================================================================
# Argument Validation
# =============================================================================

# Check if exactly three arguments are provided
# The script requires input file, output file and log file for timestamps
if [ "$#" -ne 3 ]; then
    usage
fi

# Store command line arguments in descriptive variables
input_file="$1"      # First argument: CSV log file path
output_file="$2"     # Second argument: Output file for results
log_file="$3"        # Third argument: Log timestamp file path

# Verify the existence of the input file
# If the file doesn't exist, log the issue and exit with usage message
if [ ! -f "$input_file" ]; then
    log_timestamp "Input file not detected"
    echo "Error: Input file '$input_file' does not exist."
    usage
else
    # Log successful file verification
    log_timestamp "Input file exists"
fi

# Verify the input file format using grep
# Check if the first line matches the expected CSV header format
if ! grep -q "^IP,timestamp,HTTP_method,request_path,status_code,content_length" "$input_file"; then
    echo "Warning: Input file may not be in the expected format."
    # We continue execution but log the warning
    log_timestamp "Input file format validation warning"
fi

# =============================================================================
# Output File Initialization
# =============================================================================

# Create or clear the output file to ensure we start with a blank file
# The '>' operator truncates an existing file or creates a new one
> "$output_file"

# =============================================================================
# Task (a): Extract Unique IP Addresses
# =============================================================================

# Write section header to output file
echo "Unique IP addresses:" >> "$output_file"

# Using grep & sed to extract IPs from each line
# - grep -v skips the header line by excluding it
# - sed uses a regular expression to extract just the IP address from each line
grep -v "^IP,timestamp" "$input_file" | sed -E 's/^([^,]+),.*/\1/' | sort -u >> "$output_file"

# Log completion of this task
log_timestamp "Unique IP extraction completed"

# =============================================================================
# Task (b): Identify Top 3 HTTP Methods
# =============================================================================

# Write section header to output file with a blank line before it for readability
echo -e "\nTop 3 HTTP methods:" >> "$output_file"

# Using grep & sed to extract HTTP methods and count them
# - grep -v skips the header line
# - sed extracts the HTTP method (3rd field)
# - sort groups identical methods
# - uniq -c counts occurrences
# - sort -nr sorts by count in descending order
# - head -3 takes only the top 3
grep -v "^IP,timestamp" "$input_file" | sed -E 's/[^,]*,[^,]*,([^,]*).*/\1/' | 
sort | uniq -c | sort -nr | head -3 | 
while read count method; do
    # Format and write each method with its count to the output file
    echo "$method: $count" >> "$output_file"
done

# Log completion of this task
log_timestamp "Top 3 HTTP methods identified"

# =============================================================================
# Task (c): Count Requests Per Hour
# =============================================================================

# Write section header to output file with a blank line before it for readability
echo -e "\nRequests per hour:" >> "$output_file"

# Initialize an array to store counts for each hour (0-23)
declare -a hour_counts
for i in {0..23}; do
    hour_counts[$i]=0
done

# Process log entries to count requests per hour
# Use awk for this complex processing that requires array handling and time parsing
awk -F, 'NR > 1 {
    # Extract the timestamp field and get the hour
    split($2, dt, " ");
    split(dt[2], t, ":");
    hour = t[1];
    
    # Increment count for this hour
    hours[hour]++;
} 
END {
    # No output here, we just populate the hours array
}' "$input_file" > /dev/null

# Now loop through each hour and count occurrences
for hour in {0..23}; do
    # Format hour with leading zero for proper matching in grep
    formatted_hour=$(printf "%02d" $hour)
    
    # Use grep to find lines with this hour and count them
    # - Extract the timestamp part with sed
    # - Use grep to find lines with the specific hour
    count=$(grep -v "^IP,timestamp" "$input_file" | 
           sed -E 's/[^,]*,([^,]*).*/\1/' | 
           grep -E " $formatted_hour:" | wc -l)
    
    # Write hourly count to the output file
    echo "Hour $hour: $count requests" >> "$output_file"
done

# Log completion of this task
log_timestamp "Hourly request count completed"

# =============================================================================
# Script Completion
# =============================================================================

# Log successful completion of the entire script
log_timestamp "Script execution completed"

# Display completion message to the console
echo "Processing complete. Results saved to $output_file"
echo "Execution timestamps logged to $log_file"