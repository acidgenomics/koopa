#!/usr/bin/env bash

_koopa_debian_apt_sources_file() {
    # """
    # Debian apt sources file.
    # @note Updated 2021-11-02.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_print '/etc/apt/sources.list'
}
