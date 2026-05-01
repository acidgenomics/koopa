#!/usr/bin/env bash

_koopa_append_cflags() {
    # """
    # Append strings to CFLAGS.
    # @note Updated 2023-10-19.
    # """
    local str
    _koopa_assert_has_args "$#"
    CFLAGS="${CFLAGS:-}"
    for str in "$@"
    do
        CFLAGS="${CFLAGS} ${str}"
    done
    export CFLAGS
    return 0
}
