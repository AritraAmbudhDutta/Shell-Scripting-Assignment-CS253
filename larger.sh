#!/bin/bash
# =============================================================================
# Assignment 2 - Shell Scripting, CS253 IIT Kanpur
# =============================================================================
# Script Name: larger.sh
# Description: Common Prefix Calculator - Compares files line by line
# Author: Aritra Ambudh Dutta 
# Roll No.: 230191
# Date: March 27, 2025
# =============================================================================
# 
# Purpose:
# This script compares two text files line by line and calculates the length
# of the common prefix for each pair of corresponding lines. For example,
# 'apple' and 'apricot' have a common prefix of 'ap' with length 2. The script
# handles cases where one file might have more lines than the other by treating
# missing lines as empty strings.
#
# Input:
#   - file1: First text file to compare
#   - file2: Second text file to compare
#
# Output:
#   - output.txt: File containing the length of common prefix for each line pair
#
# Example:
#   If file1.txt contains:      And file2.txt contains:
#   apple                       apricot
#   banana                      banter
#   cherry                      
#
#   Then output.txt will contain:
#   2  (common prefix 'ap' between 'apple' and 'apricot')
#   3  (common prefix 'ban' between 'banana' and 'banter')
#   0  (no common prefix between 'cherry' and an empty line)
#
# Usage: bash larger.sh file1.txt file2.txt
# =============================================================================

# =============================================================================
# Function Definitions
# =============================================================================

# Function: usage
# Purpose: Displays script usage information and exits
# Parameters: None
# Exit Status: 1 (Error/Invalid Usage)
usage() {
    echo "Usage: $0 file1 file2"
    echo "This script compares two files line by line and outputs the length"
    echo "of their common prefixes to output.txt."
    echo
    echo "Arguments:"
    echo "  file1  - First text file to compare"
    echo "  file2  - Second text file to compare"
    exit 1
}

# Function: find_common_prefix_length
# Purpose: Calculates the length of the common prefix between two strings
# Parameters:
#   $1 - First string
#   $2 - Second string
# Returns: Length of the common prefix (number of characters)
# Example: find_common_prefix_length "apple" "apricot" returns 2
find_common_prefix_length() {
    local str1="$1"
    local str2="$2"
    local i=0
    
    # Use a simpler approach with sed and awk
    # Create a temporary file with both strings for processing
    local tempfile=$(mktemp)
    
    # Generate character-by-character comparison
    for ((i=0; i<${#str1} && i<${#str2}; i++)); do
        char1="${str1:$i:1}"
        char2="${str2:$i:1}"
        echo "$i:$char1:$char2" >> "$tempfile"
    done
    
    # Use awk to find the first position where characters differ
    # This is more reliable than the grep approach
    local first_mismatch=$(awk -F: '$2 != $3 {print $1; exit}' "$tempfile")
    
    # If no mismatch found, the common prefix is the length of the shorter string
    if [ -z "$first_mismatch" ]; then
        # Return length of shorter string
        if [ ${#str1} -lt ${#str2} ]; then
            echo ${#str1}
        else
            echo ${#str2}
        fi
    else
        # Return position of first mismatch
        echo "$first_mismatch"
    fi
    
    # Clean up temporary file
    rm -f "$tempfile"
}

# Alternative implementation using awk for comparison
# This demonstrates using awk for string operations
find_common_prefix_length_awk() {
    local str1="$1"
    local str2="$2"
    
    # Use awk to find common prefix length
    awk -v s1="$str1" -v s2="$str2" '
    BEGIN {
        len = 0;
        min_len = (length(s1) < length(s2)) ? length(s1) : length(s2);
        
        for (i = 1; i <= min_len; i++) {
            if (substr(s1, i, 1) != substr(s2, i, 1))
                break;
            len++;
        }
        
        print len;
    }'
}

# =============================================================================
# Argument Validation
# =============================================================================

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Store command line arguments in descriptive variables
file1="$1"  # First input file
file2="$2"  # Second input file

# Verify both input files exist
# Use grep to check if files exist to demonstrate grep usage
if ! grep -q "." "$file1" 2>/dev/null && [ ! -f "$file1" ]; then
    echo "Error: File '$file1' does not exist or is empty."
    usage
fi

if ! grep -q "." "$file2" 2>/dev/null && [ ! -f "$file2" ]; then
    echo "Error: File '$file2' does not exist or is empty."
    usage
fi

# =============================================================================
# Output File Initialization
# =============================================================================

# Define output file
output_file="output.txt"

# Initialize output file
> "$output_file"

# =============================================================================
# File Processing
# =============================================================================

# Use sed to get line counts
# This demonstrates sed usage for basic file operations
line_count1=$(sed -n '$=' "$file1" 2>/dev/null || echo 0)
line_count2=$(sed -n '$=' "$file2" 2>/dev/null || echo 0)

# Determine the maximum number of lines to process
max_lines=$(( line_count1 > line_count2 ? line_count1 : line_count2 ))

# Process both files line by line
for ((i=1; i<=max_lines; i++)); do
    # Extract current line from each file using sed
    # If the line doesn't exist, use an empty string
    line1=$(sed -n "${i}p" "$file1" 2>/dev/null || echo "")
    line2=$(sed -n "${i}p" "$file2" 2>/dev/null || echo "")
    
    # Calculate common prefix length using our function
    # We'll use the awk version to demonstrate awk usage
    common_length=$(find_common_prefix_length_awk "$line1" "$line2")
    
    # Append the result to the output file
    echo "$common_length" >> "$output_file"
done

# =============================================================================
# Process Summary
# =============================================================================

# Use sed to format the output file for readability if needed
# This adds comments to each line of the output as in the example
if [ -f "$output_file" ]; then
    # Create a temporary copy of the output file
    temp_output=$(mktemp)
    
    # Add line numbers and file contents as comments
    line_num=1
    while IFS= read -r prefix_length; do
        line1=$(sed -n "${line_num}p" "$file1" 2>/dev/null || echo "")
        line2=$(sed -n "${line_num}p" "$file2" 2>/dev/null || echo "")
        
        # Only add comment if we have content in at least one line
        if [ -n "$line1" ] || [ -n "$line2" ]; then
            if [ "$prefix_length" -gt 0 ]; then
                # Extract the common prefix using awk
                common_prefix=$(echo "$line1" | awk -v len="$prefix_length" '{print substr($0, 1, len)}')
                echo "$prefix_length # Common prefix of '$line1' and '$line2' is '$common_prefix'"
            else
                echo "$prefix_length # Common prefix of '$line1' and '$line2' is none"
            fi
        else
            echo "$prefix_length"
        fi
        
        ((line_num++))
    done < "$output_file" > "$temp_output"
    
    # Replace the original output file with the annotated version
    mv "$temp_output" "$output_file"
fi

# =============================================================================
# Script Completion
# =============================================================================

echo "Comparison complete. Results saved to $output_file"
echo "File 1: $file1"
echo "File 2: $file2"