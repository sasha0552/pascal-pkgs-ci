#!/bin/bash -e

# Variables
root="$1"
repository="$2"
ref="$3"

# Use root directory
cd "$root"

# Directory with patches
patches_path="$root/patches/$repository/$ref"

# Go to target directory
cd "$root/$repository/$ref"

# If patches exists
if [ -d "$patches_path" ]; then
  # Apply patches
  for patch in "$patches_path"/*; do
    # Apply patch
    if [[ "$patch" == *.patch ]]; then
      # Log patch name
      echo "Applying patch $patch..."

      # Apply
      patch --no-backup-if-mismatch --strip=1 < "$patch" || exit 1
    fi

    # Apply script
    if [[ "$patch" == *.sh ]]; then
      # Log script name
      echo "Applying script $patch..."

      # Apply
      bash "$patch" || exit 1
    fi
  done
fi
