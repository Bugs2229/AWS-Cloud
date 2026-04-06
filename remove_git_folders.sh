
#!/bin/bash

# Usage: ./remove_git_folders.sh [target_directory]
# If no directory is given, uses the current directory.

TARGET="${1:-.}"

echo "Searching for .git folders in subfolders of: $TARGET"
echo "-----------------------------------------------------"

# Find .git directories one level deep in subfolders
FOUND=$(find "$TARGET" -mindepth 2 -maxdepth 3 -type d -name ".git")

if [ -z "$FOUND" ]; then
  echo "No .git folders found."
  exit 0
fi

# Show what will be removed
echo "The following .git folders will be removed:"
echo "$FOUND"
echo ""

# Confirm before deleting
read -p "Are you sure you want to delete these? (yes/no): " CONFIRM

if [ "$CONFIRM" == "yes" ]; then
  echo "$FOUND" | while read -r GIT_DIR; do
    rm -rf "$GIT_DIR"
    echo "Removed: $GIT_DIR"
  done
  echo ""
  echo "Done! All .git folders have been removed."
else
  echo "Cancelled. Nothing was deleted."
fi
