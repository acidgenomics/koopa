#!/usr/bin/env bash

main() {
    # """
    # Install tar.
    # @note Updated 2023-08-30.
    # """
    local -a conf_args install_args
    local conf_arg
    if koopa_is_macos
    then
        # iconv is detected during configure process but '-liconv' is missing
        # from 'LDFLAGS' as 1.35. Remove once iconv linking works without this.
        # See also:
        # - https://savannah.gnu.org/bugs/?64441.
        # - http://git.savannah.gnu.org/cgit/tar.git/commit/?id=8632df39
        export LDFLAGS="${LDFLAGS:-} -liconv"
    fi
    conf_args+=('--program-prefix=g')
    if koopa_is_linux
    then
        conf_args+=('--without-selinux')
    fi
    for conf_arg in "${conf_args[@]}"
    do
        install_args+=('-D' "$conf_arg")
    done
    koopa_install_gnu_app "${install_args[@]}"
    return 0
}
