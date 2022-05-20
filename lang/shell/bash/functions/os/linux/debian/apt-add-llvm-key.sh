#!/usr/bin/env bash

koopa_debian_apt_add_llvm_key() {
    # """
    # Add the LLVM key.
    # @note Updated 2021-11-09.
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='LLVM' \
        --name='llvm' \
        --url='https://apt.llvm.org/llvm-snapshot.gpg.key'
    return 0
}
