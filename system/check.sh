#!/usr/bin/env bash
set -Eeuo pipefail

# Check koopa installation.
# Modified 2019-06-12.

command -v Rscript >/dev/null 2>&1 || {
    echo >&2 "R is not installed."
    exit 1
}

Rscript --vanilla "${KOOPA_DIR}/system/check.R"
