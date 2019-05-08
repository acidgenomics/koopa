#!/usr/bin/env bash
set -Eeuxo pipefail

# Pull all git repositories.

wd=$(pwd)
git_dir="${HOME}/git"

# SC2044: For loops over find output are fragile.
# Using `-L` flag here in case git dir is a symlink.
while IFS= read -r -d '' repo
do
    repo=$(dirname "$repo")
    cd "$repo"
    pwd
    git fetch --all
    git pull --all
    git status
done <   <(find -L "$git_dir" -maxdepth 2 -type d -name ".git" -print0)

cd "$wd"
unset -v git_dir wd
