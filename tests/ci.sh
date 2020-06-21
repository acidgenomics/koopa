#!/usr/bin/env bash
set -Eeu -o pipefail

# """
# Continuous integration (CI) tests.
# @note Updated 2020-06-21.
#
# Need to navigate to koopa prefix to load '.pylintrc' file correctly.
# """

KOOPA_PREFIX="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." \
    >/dev/null 2>&1 && pwd -P)"

(
    cd "$KOOPA_PREFIX" || exit 1
    tests_dir="${KOOPA_PREFIX}/tests"
    "${tests_dir}/linter.sh"
    # Re-enable this check when documentation is complete.
    # > "${tests_dir}/help.sh"
    "${tests_dir}/shunit2.sh"
)
