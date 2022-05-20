#!/usr/bin/env bash

koopa_warn_if_export() {
    # """
    # Warn if variable is exported in current shell session.
    # @note Updated 2020-02-20.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    koopa_assert_has_args "$#"
    for arg in "$@"
    do
        if koopa_is_export "$arg"
        then
            koopa_warn "'${arg}' is exported."
        fi
    done
    return 0
}
