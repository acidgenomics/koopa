#!/usr/bin/env bash

main() { # {{{1
    # """
    # Uninstall R framework binary.
    # @note Updated 2022-04-08.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm --sudo \
        '/Applications/R.app' \
        '/Library/Frameworks/R.framework'
    koopa_rm --sudo \
        '/usr/local/bin/R' \
        '/usr/local/bin/Rscript'
    return 0
}
