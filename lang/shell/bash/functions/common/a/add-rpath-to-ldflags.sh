#!/usr/bin/env bash

koopa_add_rpath_to_ldflags() {
    # """
    # Append 'LDFLAGS' string with an rpath.
    # @note Updated 2022-04-22.
    #
    # Use '-rpath,${dir}' here not, '-rpath=${dir}'. This approach works on
    # both BSD/Unix (macOS) and Linux systems.
    # """
    local dir
    koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for dir in "$@"
    do
        LDFLAGS="${LDFLAGS} -Wl,-rpath,${dir}"
    done
    export LDFLAGS
    return 0
}
