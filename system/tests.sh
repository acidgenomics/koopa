#!/usr/bin/env bash
set -Eeu -o pipefail

# Continuous integration (CI) tests.
# Updated 2020-01-24.

script_dir="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")" \
    >/dev/null 2>&1 && pwd -P)"

tests_dir="${script_dir}/tests"

"${tests_dir}/linter.sh"

# Disabled until we switch to Dockerized unit tests.
# > "${tests_dir}/help.sh"
