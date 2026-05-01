#!/usr/bin/env bash

_koopa_arch2() {
    # """
    # Alternative platform architecture.
    # @note Updated 2023-03-18.
    #
    # e.g. Intel: amd64; ARM: arm64.
    #
    # @seealso
    # - https://wiki.debian.org/ArchitectureSpecificsMemo
    # """
    local str
    _koopa_assert_has_no_args "$#"
    str="$(_koopa_arch)"
    case "$str" in
        'aarch64')
            str='arm64'
            ;;
        'x86_64')
            str='amd64'
            ;;
    esac
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
