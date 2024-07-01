#!/usr/bin/env bash

main() {
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2024-07-01.
    # """
    koopa_rm --sudo \
        '/etc/R' \
        '/usr/lib/R'
    koopa_debian_apt_remove 'r-*'
    koopa_debian_apt_delete_repo 'r'
    koopa_debian_apt_delete_key 'r'
    return 0
}
