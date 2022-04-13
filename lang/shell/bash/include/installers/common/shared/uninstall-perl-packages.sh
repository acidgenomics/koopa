#!/usr/bin/env bash

main() {
    # """
    # Additional Perl packages uninstall cleanup.
    # @note Updated 2022-04-13.
    # """
    koopa_assert_has_no_args "$#"
    koopa_rm "${HOME:?}/.cpan" "${HOME:?}/.cpanm"
    return 0

}
