#!/usr/bin/env bash

# """
# Find lines containing more than 80 characters.
# Updated 2020-02-16.
# """

# shellcheck source=/dev/null
source "${KOOPA_PREFIX:?}/shell/bash/include/header.sh"

grep_pattern="^[^\n]{81}"

_koopa_test_find_failures "$grep_pattern"
