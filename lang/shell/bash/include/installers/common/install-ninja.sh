#!/usr/bin/env bash

# FIXME Need to install as virtualenv instead.

install_ninja() { # {{{
    # """
    # Install Ninja.
    # @note Updated 2022-03-30.
    #
    # @seealso
    # - https://github.com/ninja-build/ninja
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='ninja'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_python_pip_install \
        --prefix="${dict[prefix]}" \
        "${dict[name]}==${dict[version]}"
    return 0
}
