#!/bin/sh

_koopa_alias_kbs() {
    # """
    # Koopa 'kbs' bootstrap alias.
    # @note Updated 2024-06-15.
    # """
    _koopa_add_to_path_start "$(_koopa_xdg_data_home)/koopa-bootstrap/bin"
    return 0
}
