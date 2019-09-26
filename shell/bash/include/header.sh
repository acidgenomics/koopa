#!/usr/bin/env bash
set -Eeu -o pipefail

# Bash shared header script.
# Modified 2019-09-26.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${script_dir}/../../posix/include/functions.sh"

# Source bash functions.
functions_dir="${script_dir}/../functions"
for file in "${functions_dir}/"*".sh"
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done
