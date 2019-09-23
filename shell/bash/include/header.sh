#!/usr/bin/env bash
set -Eeu -o pipefail

# Bash shared header script.
# Modified 2019-09-23.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

shell_dir="$(dirname "$(dirname "$script_dir")")"
# shellcheck source=/dev/null
source "${shell_dir}/posix/include/functions.sh"

functions_dir="$(dirname "$script_dir")/functions"
for file in "${functions_dir}/"*".sh"
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done
