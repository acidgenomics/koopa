#!/usr/bin/env bash
set -Eeuo pipefail

# Create a dated file bucket.
# Add a `~/today` symlink for quick access.

# How to check if a symlink target matches a specific path.
# https://stackoverflow.com/questions/19860345

parent_dir="${HOME}/bucket"

# Early return if there's no bucket directory on the system.
if [[ ! -d "$parent_dir" ]]
then
    return
fi

today=$(date +%Y-%m-%d)
today_dir="${HOME}/today"

# This will check to see if we've already updated the symlink.
# SC2143: Use ! grep -q instead of comparing output with [ -z .. ]
if ! readlink "$today_dir" | grep -q "$today"
then
    bucket_today="$(date +%Y)/$(date +%m)/$(date +%Y-%m-%d)"
    mkdir -p "${parent_dir}/${bucket_today}"
    # Note the use of `-n` flag here.
    # -f, --force
    #        remove existing destination files
    # -n, --no-dereference
    #        treat LINK_NAME as a normal file if it is a symbolic link to a
    #        directory
    # -s, --symbolic
    #        make symbolic links instead of hard links
    ln -fns "${parent_dir}/${bucket_today}" "$today_dir"
fi

unset -v parent_dir today today_dir
