#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Continuous integration (CI) tests.
# @note Updated 2020-06-23.
#
# Need to navigate to koopa prefix to load '.pylintrc' file correctly.
# """

tests_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)"

(
    cd "$tests_dir" || exit 1
    "${tests_dir}/linter.sh"
    # Re-enable this check when documentation is complete.
    # > "${tests_dir}/help.sh"
    "${tests_dir}/shunit2.sh"
    # This is buggy on macOS with Homebrew.
    # > "${tests_dir}/bashcov.sh"
)
