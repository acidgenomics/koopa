#!/usr/bin/env bash
set -Eeuo pipefail

# Copy BAM and BAI (index) files to a destination.

# Source directory.
source_dir="$1"
source_dir="$( realpath $source_dir )"
if [[ ! -d "$source_dir" ]]
then
    printf "\nDoes not exist:\n$source_dir\n\n"
    exit 1
fi

# Destination directory.
dest_dir="$2"
dest_dir="$( realpath $dest_dir )"
if [[ ! -d "$dest_dir" ]]
then
    printf "\nDoes not exist:\n$dest_dir\n\n"
    exit 1
fi

printf "\n"
printf "Source:\n$source_dir\n"
printf "\n"
printf "Destination:\n$dest_dir\n"
printf "\n"

# Note that we're allowing symlinks in the search path.
# -L  follow symbolic links

find -L "$source_dir" \
    -maxdepth 1 \
    -name "*.bam" -print0 -o -name "*.bam.bai" \
    -print0 | xargs -0 -I {} \
    cp -irv {} "$dest_dir"
