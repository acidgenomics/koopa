#!/usr/bin/env bash

# FIXME Confirm that this no longer errors if the 'koopa-r.list' repo
# file isn't present.

main() {
    # """
    # Uninstall R CRAN binary.
    # @note Updated 2022-01-28.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/etc/R' \
        '/usr/lib/R/etc'
    koopa_debian_apt_remove 'r-*'
    koopa_debian_apt_delete_repo 'r'
    return 0
}
