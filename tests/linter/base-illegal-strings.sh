#!/usr/bin/env bash

# """
# Find illegal strings.
# Updated 2020-02-16.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

# shellcheck disable=SC2016
illegal_strings=(
    ' path='
    '; do'
    '; then'
    '<  <'
    '<<<<<<<'
    '>>>>>>>'
    'IFS=  '
    '\$path'
    '\bFIXME\b'
    '\bTODO\b'
    '^path='
    'os.system'
)
grep_pattern="$(_koopa_paste0 '|' "${illegal_strings[@]}")"

_koopa_test_find_failures "$grep_pattern"
