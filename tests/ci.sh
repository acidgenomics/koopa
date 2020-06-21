#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Continuous integration (CI) tests.
# Updated 2020-02-04.
# """

tests_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"

"${tests_dir}/linter.sh"
# > "${tests_dir}/help.sh"
"${tests_dir}/shunit2.sh"
