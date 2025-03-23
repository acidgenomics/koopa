#!/usr/bin/env bash

koopa_add_rpath_to_ldflags() {
    # """
    # Append 'LDFLAGS' string with an rpath.
    # @note Updated 2023-10-09.
    #
    # Use '-rpath,${dir}' here not, '-rpath=${dir}'. This approach works on
    # both BSD/Unix (macOS) and Linux systems.
    # """
    local dir
    koopa_assert_has_args "$#"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        koopa_append_ldflags "-Wl,-rpath,${dir}"
    done
    return 0
}
