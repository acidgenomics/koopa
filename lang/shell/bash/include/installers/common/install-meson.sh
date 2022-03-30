#!/usr/bin/env bash

install_meson() { # {{{
    # """
    # Install Meson.
    # @note Updated 2022-03-30.
    #
    # @seealso
    # - https://github.com/mesonbuild/meson
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='meson'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[libexec]="${dict[prefix]}/libexec"
    koopa_python_create_venv \
        --prefix="${dict[libexec]}" \
        "${dict[name]}==${dict[version]}"
    koopa_ln \
        "${dict[libexec]}/bin/${dict[name]}" \
        "${dict[prefix]}/bin/${dict[name]}"
    return 0
}
