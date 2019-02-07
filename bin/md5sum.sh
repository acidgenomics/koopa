#!/usr/bin/env bash
set -Eeuo pipefail

# Run md5sum and generate an MD5 checksum file.

md5sum "$@" 2>&1 | tee "md5sum-$(date +%F).md5"
