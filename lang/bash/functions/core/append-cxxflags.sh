#!/usr/bin/env bash

_koopa_append_cxxflags() {
    # """
    # Append strings to CXXFLAGS.
    # @note Updated 2024-09-19.
    # """
    local str
    _koopa_assert_has_args "$#"
    CXXFLAGS="${CXXFLAGS:-}"
    for str in "$@"
    do
        CXXFLAGS="${CXXFLAGS} ${str}"
    done
    export CXXFLAGS
    return 0
}
