#!/usr/bin/env bash

# """
# Run pylint on all Python scripts.
# Updated 2020-06-20.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

_koopa_exit_if_not_installed flake8

# Find files by shebang.
grep_pattern='^#!/.*\bpython(3)?\b$'
readarray -t files <<< "$(_koopa_test_find_files_by_shebang "$grep_pattern")"

flake8 --ignore E402,W503 "${files[@]}"

name="$(_koopa_basename_sans_ext "$0")"
_koopa_status_ok "${name} [${#files[@]}]"
