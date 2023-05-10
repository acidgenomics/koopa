#!/usr/bin/env bash

koopa_debian_apt_remove() {
    # """
    # Remove Debian apt package.
    # @note Updated 2023-05-10.
    # """
    koopa_assert_has_args "$#"
    koopa_debian_apt_get purge "$@"
    koopa_debian_apt_clean
    return 0
}
