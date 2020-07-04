#!/usr/bin/env bash

# """
# Run pylint on all Python scripts.
# Updated 2020-06-20.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

koopa::exit_if_not_installed pylint

# Find files by shebang.
grep_pattern='^#!/.*\bpython(3)?\b$'
readarray -t files <<< "$(koopa::test_find_files_by_shebang "$grep_pattern")"

# Note that setting '--jobs=0' flag here enables multicore.
pylint --jobs=0 --score=n "${files[@]}"

name="$(koopa::basename_sans_ext "$0")"
koopa::status_ok "${name} [${#files[@]}]"
