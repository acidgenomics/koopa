#!/usr/bin/env bash

main() {
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2022-10-13.
    # """
    koopa_rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc'
    koopa_debian_apt_remove 'r-*'
    koopa_debian_apt_delete_repo 'r'
    return 0
}
