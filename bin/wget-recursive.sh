#!/usr/bin/env bash
set -Eeuo pipefail

# Recursively download a directory using wget.

# This script requires wget.
# https://www.gnu.org/software/wget/
command -v wget >/dev/null 2>&1 || { echo >&2 "wget missing."; exit 1; }

url="$1"
user="$2"

# Note that we need to escape the wildcards in the password.
# For direct input, can just use single quotes to escape.
# See also:
# - https://unix.stackexchange.com/questions/379181
password="$3"
password="${password@Q}"

# --background
# --tries=20

wget \
    --user="$user" \
    --password="$password" \
    --recursive \
    --no-parent \
    --continue \
    --debug \
    --output-file="wget_$(date +%F).log" \
    "$url"/*

unset -v password url user
