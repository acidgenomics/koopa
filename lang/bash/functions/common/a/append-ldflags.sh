#!/usr/bin/env bash

koopa_append_ldflags() {
    # """
    # Append strings to LDFLAGS.
    # @note Updated 2023-10-09.
    # """
    local str
    koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for str in "$@"
    do
        LDFLAGS="${LDFLAGS} ${str}"
    done
    export LDFLAGS
    return 0
}
