#!/bin/bash

declare -A CSV_ARRAY
MAX_ROW=0
MAX_COL=0

# Returns true if CSV_ARRAY has a length of 0
function Is_Array_Empty() {
  # If the length of the array is 0 then
  if (( ${#CSV_ARRAY[@]} == 0 )); then
    # Return 0 (True) (returns won't show on STDOUT)
    return 0
  else
    # Return 1 (False) (returns won't show on STDOUT)
    return 1
  fi
}

# Assigns a given csv to the CSV_ARRAY
function Assign_To_Array() {
  local ROW_NUM     # Row number
  local COL_NUM     # Column number
  local LINE_LENGTH # Length (number of items) for the given line
  local READ_VALUE  # Value of the item in given line
  local INDICIES    # Indicies used in the associative array
  
  # Using ',' as an Internal Field Seperator (IFS), read through each line in a
  # file, given as a filepath as the first parameter
  while IFS=, read -r -a LINE_ARRAY
  do
    # Track the row currently being read
    ROW_NUM="$((ROW_NUM+1))"

    # Get the length (number of items) for the given line
    LINE_LENGTH=${#LINE_ARRAY[@]}

    # For each item in the given line
    for ((i = 0 ; i < LINE_LENGTH ; i++));
    do
      # Track the column being currently read
      COL_NUM="$((i+1))"

      # Get the value of the item in the array
      READ_VALUE=${LINE_ARRAY["$i"]}

      # Build the "association" to be used as the CSV_ARRAY indicies
      INDICIES="$ROW_NUM,$COL_NUM"

      # Load the value into the CSV_ARRAY
      CSV_ARRAY["$INDICIES"]="$READ_VALUE"
    done
  done < "$1"

  # Assigning max rows and columns
  MAX_ROW="$ROW_NUM"
  MAX_COL="$COL_NUM"
}

# Reads a value from the CSV_ARRAY
function Read_From_Array() {
  local INDICIES # Indicies used in the associative array

  # First two arguments are the Row and Column for the target value. Its 
  # "association" is built here
  INDICIES="$1,$2"
  
  # Double-check if the array is empty to prevent displaying non-existant values
  if Is_Array_Empty; then
    echo "IMPORTED CSV IS BLANK"
  else
    # Return the value held in the associative array
    echo "${CSV_ARRAY["$INDICIES"]}"
  fi
}

# Writes a value to the CSV_ARRAY
function Write_To_Array() {
  local INDICIES # Indicies used in the associative array

  # First two arguments are the Row and Column for the target value. Its 
  # "association" is built here
  INDICIES="$1,$2"
  
  # Double-check if the array is empty to prevent displaying non-existant values
  if Is_Array_Empty; then
    echo "IMPORTED CSV IS BLANK"
  else
    # Assign value in associative array
    CSV_ARRAY["$INDICIES"]=$3

    # Notify user the value has been updated
    echo "(R$ROW_NUM,C$COL_NUM) => ${CSV_ARRAY["$INDICIES"]}"
  fi
}

# Prints out all values in the same form as the original CSV from CSV_ARRAY
function Print() {
  # Variable to hold the line to be built before printing
  PRINT_LINE=""

  # Double-check if the array is empty to prevent displaying non-existant values
  if Is_Array_Empty; then
    echo "IMPORTED CSV IS BLANK"
  else
    # For each row
    for ((i = 1 ; i <= MAX_ROW ; i++));
    do
      # For each column
      for ((j = 1 ; j <= MAX_COL ; j++));
      do
        # If we hit the max column, exclude the comma
        if ((j != MAX_COL)); then
          PRINT_LINE+="$(Read_From_Array $i $j),"
        else
          PRINT_LINE+="$(Read_From_Array $i $j)"
        fi
      done
      
      # Print the reconstructed line
      echo "$PRINT_LINE"

      # Reset the PRINT_LINE variable
      PRINT_LINE=""

    done
  fi
}

# Redirects Print function output to file
function Save_To_File() {
  # Redirects Print output to file
  Print > "$1"
}
