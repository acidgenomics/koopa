#!/usr/bin/env bash

main() {
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2023-05-12.
    # """
    _koopa_rm --sudo \
        '/etc/R' \
        '/usr/lib/R'
    _koopa_debian_apt_remove 'r-*'
    _koopa_debian_apt_delete_repo 'r'
    return 0
}
