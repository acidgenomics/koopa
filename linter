#!/usr/bin/env bash
set -Eeu -o pipefail

# Linter checks.
# Updated 2019-07-27.

linter_dir="${KOOPA_HOME}/system/linter"
for file in "${linter_dir}/"*".sh"
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && "$file"
done
unset -v linter_dir
