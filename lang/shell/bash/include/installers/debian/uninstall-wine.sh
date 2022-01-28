#!/usr/bin/env bash

koopa:::debian_uninstall_wine() { # {{{1
    # """
    # Uninstall Wine.
    # @note Updated 2022-01-28.
    # """
    koopa::debian_apt_remove 'wine-*'
    koopa::debian_apt_delete_repo 'wine' 'wine-obs'
}
