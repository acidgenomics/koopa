#!/bin/sh

_koopa_alias_kbs() {
    # """
    # Koopa 'kbs' bootstrap alias.
    # @note Updated 2024-06-15.
    # """
    _koopa_add_to_path_start "$(_koopa_bootstrap_prefix)/bin"
    return 0
}
