#!/usr/bin/env bash
# koopa nolint=coreutils

# """
# Raspbian Linux header.
# @note Updated 2020-07-23.
# """

if [[ -z "${KOOPA_PREFIX:-}" ]]
then
    KOOPA_PREFIX="$( \
        cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." \
        &>/dev/null \
        && pwd -P \
    )"
    export KOOPA_PREFIX
fi

# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

koopa::assert_is_raspbian
