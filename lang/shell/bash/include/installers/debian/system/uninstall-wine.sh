#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-28.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_remove 'wine-*'
    koopa_debian_apt_delete_repo 'wine' 'wine-obs'
    return 0
}
