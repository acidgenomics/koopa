#!/usr/bin/env bash

main() {
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-28.
    # """
    _koopa_debian_apt_remove 'wine-*'
    _koopa_debian_apt_delete_repo 'wine' 'wine-obs'
    return 0
}
