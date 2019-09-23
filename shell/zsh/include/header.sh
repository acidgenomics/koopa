#!/usr/bin/env bash
set -eu -o pipefail

# ZSH shared header script.
# Modified 2019-09-23.

script_dir="$(cd "$(dirname "${(%):-%N}")" >/dev/null 2>&1 && pwd -P)"

shell_dir="$(dirname "$(dirname "$script_dir")")"
# shellcheck source=/dev/null
source "${shell_dir}/posix/include/functions.sh"
