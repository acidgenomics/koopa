#!/usr/bin/env bash

koopa_append_cppflags() {
    # """
    # Append strings to CPPFLAGS.
    # @note Updated 2023-10-10.
    # """
    local str
    koopa_assert_has_args "$#"
    CPPFLAGS="${CPPFLAGS:-}"
    for str in "$@"
    do
        CPPFLAGS="${CPPFLAGS} ${str}"
    done
    export CPPFLAGS
    return 0
}
