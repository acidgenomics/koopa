#!/usr/bin/env bash
set -Eeuxo pipefail

# Set default permissions.

user="$USER"
group="id -gn ${user}"

chown -R "${user}:${group}" ./*

# Files
find . -type f -print0 | xargs -0 -I {} chmod u=rw,g=rw,o=r {}

# Directories
# find . -type d -print0 | xargs -0 -I {} chmod u=rwx,g=rws,o=rx {}
find . -type d -print0 | xargs -0 -I {} chmod u=rwx,g=rwx,o=rx {}

unset -v user group
