#!/usr/bin/env bash

_koopa_debian_apt_install() {
    # """
    # Install Debian apt package.
    # @note Updated 2023-05-10.
    # """
    _koopa_assert_has_args "$#"
    _koopa_debian_apt_get update
    _koopa_debian_apt_get install "$@"
    return 0
}
