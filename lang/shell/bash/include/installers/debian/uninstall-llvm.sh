#!/usr/bin/env bash

# FIXME Indicate that this is a binary install.

debian_uninstall_llvm() { # {{{1
    # """
    # Uninstall LLVM.
    # @note Updated 2022-01-31.
    # """
    local app
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    "${app[sudo]}" "${app[apt_get]}" --yes remove \
        '^clang-[0-9]+.*' \
        '^llvm-[0-9]+.*'
    "${app[sudo]}" "${app[apt_get]}" --yes autoremove
    koopa_rm --sudo '/etc/apt/sources.list.d/llvm.list'
    return 0
}
