#!/bin/zsh

# Loop through all .circom files in the current directory
for file in *.circom; do
    # Check if the file exists (handles case where no .circom files exist)
    if [[ -f "$file" ]]; then
        echo "Compiling $file..."
        # Run circom command with the current file
        circom "$file"
        
        # Check if the command succeeded
        if [[ $? -eq 0 ]]; then
            echo "Successfully compiled $file"
        else
            echo "Failed to compile $file" >&2
        fi
    fi
done

# If no .circom files were found
if [[ $(ls *.circom 2>/dev/null | wc -l) -eq 0 ]]; then
    echo "No .circom files found in the current directory"
fi