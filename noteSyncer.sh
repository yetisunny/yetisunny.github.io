#!/bin/bash

# CONFIGURATION
SOURCE_DIR="/home/luuk/Obsidian/Vault"
DEST_DIR="/home/luuk/quartz/content"

# Ensure destination exists
mkdir -p "$DEST_DIR"

# Recursively find all markdown files under SOURCE_DIR
find "$SOURCE_DIR" -type f -name "*.md" | while read -r file; do
    # Read the frontmatter
    if grep -q "^---" "$file"; then
        frontmatter=$(awk '/^---/{flag=flag+1; next} flag==1' "$file" | awk '/^---/{exit} {print}')
        
        if echo "$frontmatter" | grep -q "^published:\s*true"; then
            # Compute the relative path
            rel_path="${file#$SOURCE_DIR/}"
            dest_path="$DEST_DIR/$rel_path"

            # Create destination directory if needed
            mkdir -p "$(dirname "$dest_path")"

            # Copy file
            cp "$file" "$dest_path"
            echo "Copied: $rel_path"
        else
            echo "Skipped (no published:true): $file"
        fi
    else
        echo "Skipped (no frontmatter): $file"
    fi
done
