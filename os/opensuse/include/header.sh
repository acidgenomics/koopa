#!/usr/bin/env bash

# """
# openSUSE Linux header.
# @note Updated 2020-07-17.
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
source "${KOOPA_PREFIX}/os/linux/include/header.sh"
for file in "${KOOPA_PREFIX}/shell/bash/functions/os/opensuse/"*'.sh'
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done
unset -v file

koopa::assert_is_opensuse
