#!/usr/bin/env bash
set -Eeu -o pipefail

# Bash internal functions.
# Modified 2019-06-21.

# shellcheck source=/dev/null
source "${KOOPA_DIR}/system/include/functions.sh"

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
functions_dir="$(dirname "$script_dir")/functions"

for file in "${functions_dir}/"*".sh"
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done
