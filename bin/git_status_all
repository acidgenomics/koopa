#!/usr/bin/env bash
set -Eeuo pipefail

# Get the status of all local git repositories.

wd=$(pwd)
git_dir="${HOME}/git"

# SC2044: For loops over find output are fragile.
# Using `-L` flag here in case git dir is a symlink.
while IFS= read -r -d '' repo
do
    repo=$(dirname "$repo")
    cd "$repo"
    pwd
    git status
done <   <(find -L "$git_dir" -type d -name ".git" -print0)

cd "$wd"
