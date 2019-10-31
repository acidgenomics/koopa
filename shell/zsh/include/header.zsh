#!/usr/bin/env zsh
set -eu -o pipefail

# ZSH shared header script.
# Updated 2019-10-28.

script_dir="$(cd "$(dirname "${(%):-%N}")" >/dev/null 2>&1 && pwd -P)"

# Source POSIX functions.
# shellcheck source=/dev/null
source "${script_dir}/../../posix/include/functions.sh"

# Source ZSH functions.
# shellcheck source=/dev/null
# > source "${script_dir}/functions.sh"
