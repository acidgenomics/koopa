#!/usr/bin/env bash

koopa_debian_apt_sources_prefix() {
    # """
    # Debian apt sources directory.
    # @note Updated 2021-11-02.
    # """
    koopa_assert_has_no_args "$#"
    koopa_print '/etc/apt/sources.list.d'
}
