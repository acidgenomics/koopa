#!/usr/bin/env bash

# FIXME Ensure we unlink in koopa bin.

main() {
    # """
    # Uninstall LLVM.
    # @note Updated 2022-01-31.
    # """
    local app
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [apt_get]="$(koopa_debian_locate_apt_get)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['apt_get']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    "${app['sudo']}" "${app['apt_get']}" --yes remove \
        '^clang-[0-9]+.*' \
        '^llvm-[0-9]+.*'
    "${app['sudo']}" "${app['apt_get']}" --yes autoremove
    koopa_rm --sudo '/etc/apt/sources.list.d/llvm.list'
    return 0
}
