#!/usr/bin/env bash

koopa:::debian_uninstall_llvm() { # {{{1
    # """
    # Uninstall LLVM.
    # @note Updated 2022-01-31.
    # """
    local app
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa::debian_locate_apt_get)"
        [sudo]="$(koopa::locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes remove \
        '^clang-[0-9]+.*' \
        '^llvm-[0-9]+.*'
    "${app[sudo]}" "${app[apt_get]}" --yes autoremove
    koopa::rm --sudo '/etc/apt/sources.list.d/llvm.list'
    return 0
}
