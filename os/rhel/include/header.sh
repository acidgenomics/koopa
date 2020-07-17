#!/usr/bin/env bash

# """
# Red Hat Enterprise Linux (RHEL) header.
# @note Updated 2020-07-17.
# """

koopa_prefix="$( \
    cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../../.." \
    &>/dev/null \
    && pwd -P \
)"
# shellcheck source=/dev/null
source "${koopa_prefix}/os/fedora/include/header.sh"
for file in "${koopa_prefix}/shell/bash/functions/os/rhel/"*'.sh'
do
    # shellcheck source=/dev/null
    [[ -f "$file" ]] && source "$file"
done
unset -v file koopa_prefix
koopa::assert_is_rhel
