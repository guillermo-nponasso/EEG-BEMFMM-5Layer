#!/bin/bash

# Get the parent directory containing subfolders (relative path)
parent_dir="."

# Iterate over each subfolder
for folder_name in "$parent_dir"/*/; do
    # Check if the folder is actually a directory
    if [ -d "$folder_name" ]; then
        # Find the zip file in the current subfolder
        zip_file=$(find "$folder_name" -maxdepth 1 -type f -iname "*.zip")

        # If a zip file is found, unzip it into a folder with the same name as the zip file
        if [ -n "$zip_file" ]; then
            # Get the base name of the zip file (without the extension)
            base_name=$(basename -s .zip "$zip_file")
            
            # Create a directory with the same name as the zip file (without the .zip extension)
            mkdir -p "$folder_name/$base_name"
            
            # Unzip the contents into the created directory
            unzip -d "$folder_name/$base_name" "$zip_file"
            echo "Unzipped $zip_file into $folder_name/$base_name"
        else
            echo "No zip file found in $folder_name"
        fi
    fi
done

