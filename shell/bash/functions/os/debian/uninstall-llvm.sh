#!/usr/bin/env bash

koopa::debian_uninstall_llvm() { # {{{1
    # """
    # Uninstall LLVM.
    # @note Updated 2020-07-16.
    # """
    name_fancy='LLVM'
    koopa::uninstall_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    unset -v LLVM_CONFIG
    sudo apt-get --yes remove '^clang-[0-9]+.*' '^llvm-[0-9]+.*'
    sudo apt-get --yes autoremove
    koopa::rm -S '/etc/apt/sources.list.d/llvm.list'
    koopa::uninstall_success "$name_fancy"
    return 0
}
