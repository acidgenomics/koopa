#!/usr/bin/env bash

main() {
    # """
    # Uninstall Pandoc.
    # @note Updated 2022-04-04.
    #
    # May not need (or want) to install 'pandoc-data' here.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_remove 'pandoc' 'pandoc-data'
    return 0
}
