#!/usr/bin/env bash

main() {
    # """
    # Install Prelude Emacs.
    # @note Updated 2023-04-06.
    #
    # @seealso
    # - https://prelude.emacsredux.com/en/latest/
    # """
    local -A dict
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://github.com/bbatsov/prelude.git'
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    koopa_prelude_emacs --no-window-system
    return 0
}
