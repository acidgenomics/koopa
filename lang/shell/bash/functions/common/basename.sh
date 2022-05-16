#!/usr/bin/env bash

koopa_basename() {
    # """
    # Extract the file basename.
    # @note Updated 2021-05-21.
    #
    # Parameterized, supporting multiple basename extractions.
    #
    # @seealso
    # - https://stackoverflow.com/questions/22401091/
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        koopa_print "${arg##*/}"
    done
    return 0
}
