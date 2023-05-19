#!/usr/bin/env bash

koopa_debian_apt_key_prefix() {
    # """
    # Debian apt key prefix.
    # @note Updated 2021-11-02.
    # @seealso
    # - '/etc/apt/trusted.gpg.d' (alternate location for apt).
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '/usr/share/keyrings'
}
