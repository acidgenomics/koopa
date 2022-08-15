#!/usr/bin/env bash

main() {
    # """
    # Install SCONS.
    # @note Updated 2022-04-09.
    #
    # Required to install Apache Serf, which is required by subversion for
    # HTTPS downloads.
    #
    # @seealso
    # - https://scons.org/
    # - https://gist.github.com/sgykfjsm/1dc5378d0258ae370fca
    # """
    local app conf_args dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [name]='SCons'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    koopa_python_create_venv \
        --prefix="${dict[prefix]}/libexec" \
        "${dict[name]}==${dict[version]}"
    koopa_ln \
        "${dict[prefix]}/libexec/bin/scons" \
        "${dict[prefix]}/bin/scons"
    return 0
}
