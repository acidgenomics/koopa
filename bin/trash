#!/usr/bin/env bash
set -Eeuxo pipefail

# Move files to the Trash folder instead of deleting.

trash_dir="${HOME}/.Trash/"
mkdir -p "$trash_dir"
mv "$@" "$trash_dir"
