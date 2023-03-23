#!/usr/bin/env bash

main() {
    # """
    # Uninstall R framework binary.
    # @note Updated 2022-03-22.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    # > koopa_macos_uninstall_system_openmp
    koopa_rm --sudo \
        '/usr/local/bin/R' \
        '/usr/local/bin/Rscript'
    return 0
}
