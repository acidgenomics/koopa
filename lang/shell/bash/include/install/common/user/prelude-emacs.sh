#!/usr/bin/env bash

main() {
    # """
    # Install Prelude Emacs.
    # @note Updated 2022-09-16.
    #
    # @seealso
    # - https://prelude.emacsredux.com/en/latest/
    # """
    local dict
    koopa_assert_has_no_args "$#"
    local -A dict=(
        ['commit']="${KOOPA_INSTALL_VERSION:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url']='https://github.com/bbatsov/prelude.git'
    )
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    koopa_prelude_emacs --no-window-system
    return 0
}
