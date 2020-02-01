#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Continuous integration (CI) tests.
# Updated 2020-02-01.
# """

tests_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"

"${tests_dir}/linter.sh"

# Disabled until we switch to Dockerized unit tests.
# > "${tests_dir}/help.sh"

"${tests_dir}/shunit2.sh"
