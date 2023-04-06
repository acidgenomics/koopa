#!/usr/bin/env bash

koopa_make_build_string() {
    # """
    # OS build string for 'make' configuration.
    # @note Updated 2023-04-06.
    #
    # Use this for 'configure --build' flag.
    #
    # - macOS: x86_64-darwin15.6.0
    # - Linux: x86_64-linux-gnu
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['arch']="$(koopa_arch)"
    if koopa_is_linux
    then
        dict['os_type']='linux-gnu'
    else
        dict['os_type']="$(koopa_os_type)"
    fi
    koopa_print "${dict['arch']}-${dict['os_type']}"
    return 0
}
