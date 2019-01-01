#!/usr/bin/env bash
set -Eeuo pipefail

# Move files up 1 directory level.

find . -type f -mindepth 2 -exec mv {} . \;
find . -mindepth 2
find . -type d -delete
