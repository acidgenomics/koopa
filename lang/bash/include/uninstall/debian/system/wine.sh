#!/usr/bin/env bash

main() {
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-28.
    # """
    koopa_debian_apt_remove 'wine-*'
    koopa_debian_apt_delete_repo 'wine' 'wine-obs'
    return 0
}
