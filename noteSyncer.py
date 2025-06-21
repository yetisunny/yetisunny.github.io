import os
import shutil
import yaml

# Paths — change as needed
SOURCE_DIR = "~/Obsidian/Vault/"
DEST_DIR = "~/quartz/content/"

def has_publish_true(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    if lines[0].strip() != '---': return False  # No frontmatter

    frontmatter = []
    for line in lines[1:]:
        if line.strip() == '---':
            break
        frontmatter.append(line)

    try:
        metadata = yaml.safe_load(''.join(frontmatter))
        return metadata.get('publish', False) is True
    except Exception as e:
        print(f"Error parsing YAML in {filepath}: {e}")
        return False

def sync_notes():
    if not os.path.exists(DEST_DIR):
        os.makedirs(DEST_DIR)

    for filename in os.listdir(SOURCE_DIR):
        if filename.endswith(".md"):
            source_path = os.path.join(SOURCE_DIR, filename)
            if has_publish_true(source_path):
                dest_path = os.path.join(DEST_DIR, filename)
                shutil.copy2(source_path, dest_path)
                print(f"Copied: {filename}")
            else:
                print(f"Skipped: {filename}")

if __name__ == "__main__":
    sync_notes()

