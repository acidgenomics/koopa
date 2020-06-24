#!/usr/bin/env bash

# """
# Run ShellCheck on all Bash and Zsh scripts.
# Updated 2020-06-20.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

_koopa_exit_if_not_installed shellcheck

# Find files by shebang.
grep_pattern='^#!/.*\b(ba)?sh\b$'
readarray -t files <<< "$(_koopa_test_find_files_by_shebang "$grep_pattern")"

shellcheck -x "${files[@]}"

name="$(_koopa_basename_sans_ext "$0")"
_koopa_status_ok "${name} [${#files[@]}]"
