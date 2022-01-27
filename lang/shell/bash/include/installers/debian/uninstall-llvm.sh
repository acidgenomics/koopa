#!/usr/bin/env bash

koopa:::debian_uninstall_llvm() { # {{{1
    # """
    # Uninstall LLVM.
    # @note Updated 2022-01-27.
    # """
    koopa::assert_has_no_args "$#"
    sudo apt-get --yes remove '^clang-[0-9]+.*' '^llvm-[0-9]+.*'
    sudo apt-get --yes autoremove
    koopa::rm --sudo '/etc/apt/sources.list.d/llvm.list'
    return 0
}
