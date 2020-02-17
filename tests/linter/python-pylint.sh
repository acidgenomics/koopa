#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$(koopa header bash)"

# """
# Run pylint on all Python scripts.
# Updated 2020-02-16.
# """

_koopa_exit_if_not_installed pylint

# Find files by shebang.
grep_pattern='^#!/.*\bpython(3)?\b$'
mapfile -t files < <(_koopa_test_find_files_by_shebang "$grep_pattern")

# Note that setting '--jobs=0' flag here enables multicore.
python3 -m pylint --jobs=0 --score=n "${files[@]}"

name="$(_koopa_basename_sans_ext "$0")"
_koopa_status_ok "${name} [${#files[@]}]"
