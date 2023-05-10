#!/usr/bin/env bash

koopa_debian_apt_install() {
    # """
    # Install Debian apt package.
    # @note Updated 2023-05-10.
    # """
    koopa_assert_has_args "$#"
    koopa_debian_apt_get update
    koopa_debian_apt_get install "$@"
    return 0
}
