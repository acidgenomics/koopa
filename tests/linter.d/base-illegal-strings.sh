#!/usr/bin/env bash

# """
# Find illegal strings.
# Updated 2020-03-06.
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
grep_pattern="$(koopa::paste0 '|' "${illegal_strings[@]}")"
koopa::test_find_failures "$grep_pattern" 'illegal-strings'
