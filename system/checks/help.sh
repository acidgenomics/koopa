#!/usr/bin/env bash
set -Eeu -o pipefail

# Check that all scripts support '--help' flag.
# Updated 2019-09-27.

KOOPA_HOME="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." \
    >/dev/null 2>&1 && pwd -P)"

find "${KOOPA_HOME}/bin" -type f -print0 | \
    xargs -0 -I {} nice {} --help > /dev/null
