#!/usr/bin/env bash

_koopa_debian_apt_remove() {
    # """
    # Remove Debian apt package.
    # @note Updated 2023-05-10.
    # """
    _koopa_assert_has_args "$#"
    _koopa_debian_apt_get purge "$@"
    _koopa_debian_apt_clean
    return 0
}
