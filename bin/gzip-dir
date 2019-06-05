#!/usr/bin/env bash
set -Eeuo pipefail

# Create a gzipped tar file from current working directory.

find . -mindepth 1 -maxdepth 1 -type d -exec tar -zcvf {}.tar.gz {} \;
