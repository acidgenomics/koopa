#!/usr/bin/env bash
set -Eeuo pipefail

file="$1"
vim -c :sort -c :wq -E -s "$file"
