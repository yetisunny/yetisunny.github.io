#!/bin/bash

SOURCE_DIR="/home/luuk/Obsidian/Vault"
DEST_DIR="/home/luuk/quartz/content"
IMAGES_SUBDIR="Images"

mkdir -p "$DEST_DIR"

# 1. Copy published notes
echo "Copying published notes..."
published_notes=()

find "$SOURCE_DIR" -type f -name "*.md" | while read -r file; do
    if grep -q "^---" "$file"; then
        frontmatter=$(awk '/^---/{flag=flag+1; next} flag==1' "$file" | awk '/^---/{exit} {print}')
        if echo "$frontmatter" | grep -q "^published:\s*true"; then
            rel_path="${file#$SOURCE_DIR/}"
            dest_path="$DEST_DIR/$rel_path"

            mkdir -p "$(dirname "$dest_path")"
            cp "$file" "$dest_path"
            echo "Copied note: $rel_path"

            published_notes+=("$file")
        else
            echo "Skipped (not published): $file"
        fi
    else
        echo "Skipped (no frontmatter): $file"
    fi
done

# 2. Scan published notes for Obsidian-style image links
echo "Looking for image references in notes..."
image_paths=()

for note in "${published_notes[@]}"; do
    grep -oP '!\[\[\K[^]]+\.(png|jpg|jpeg|gif|svg)' "$note" | while read -r imgname; do
        full_img_path="$SOURCE_DIR/$IMAGES_SUBDIR/$imgname"
        if [ -f "$full_img_path" ]; then
            image_paths+=("$full_img_path")
        else
            echo "Warning: Image not found: $imgname"
        fi
    done
done

# 3. Deduplicate and copy referenced images
unique_image_paths=($(printf "%s\n" "${image_paths[@]}" | sort -u))

echo "Copying images..."
for img in "${unique_image_paths[@]}"; do
    rel_path="${img#$SOURCE_DIR/}"
    dest_path="$DEST_DIR/$rel_path"
    mkdir -p "$(dirname "$dest_path")"
    cp "$img" "$dest_path"
    echo "Copied image: $rel_path"
done
