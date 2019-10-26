#!/usr/bin/env bash
set -Eeu -o pipefail

# Check that all scripts support '--help' flag.
# Updated 2019-10-26.

KOOPA_HOME="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../.." \
    >/dev/null 2>&1 && pwd -P)"
export KOOPA_HOME

find "${KOOPA_HOME}/bin" -type f -print0 | \
    xargs -0 -I {} nice {} --help > /dev/null
