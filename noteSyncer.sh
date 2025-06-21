
#!/bin/bash

# CONFIGURATION
SOURCE_DIR="/home/luuk/Obsidian/Vault/"
DEST_DIR="/home/luuk/quartz/content/"

# Ensure destination exists
mkdir -p "$DEST_DIR"

# Find all markdown files
find "$SOURCE_DIR" -type f -name "*.md" | while read -r file; do
    # Read the frontmatter
    if grep -q "^---" "$file"; then
        # Extract frontmatter block
        frontmatter=$(awk '/^---/{flag=flag+1; next} flag==1' "$file" | awk '/^---/{exit} {print}')
        
        # Check for publish: true
        if echo "$frontmatter" | grep -q "^published:\s*true"; then
            # Get relative path
            rel_path="${file#$SOURCE_DIR/}"
            dest_path="$DEST_DIR/$rel_path"

            # Create destination folder if needed
            mkdir -p "$(dirname "$dest_path")"

            # Copy the file
            cp "$file" "$dest_path"
            echo "Copied: $rel_path"
        else
            echo "Skipped (no published:true): $file"
        fi
    else
        echo "Skipped (no frontmatter): $file"
    fi
done
