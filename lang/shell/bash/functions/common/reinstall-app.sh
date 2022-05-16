#!/usr/bin/env bash

koopa_reinstall_app() {
    # """
    # Reinstall an application (alias).
    # @note Updated 2022-01-21.
    # """
    koopa_assert_has_args "$#"
    koopa_koopa install "$@" --reinstall
}
