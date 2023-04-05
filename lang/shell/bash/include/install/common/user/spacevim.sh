#!/usr/bin/env bash

main() {
    # """
    # Install SpaceVim.
    # @note Updated 2022-09-16.
    #
    # @seealso
    # - https://spacevim.org
    # - https://spacevim.org/quick-start-guide/
    # - https://spacevim.org/faq/
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    local -A app=(
        ['make']="$(koopa_locate_make)"
    )
    [[ -x "${app['make']}" ]] || exit 1
    local -A dict=(
        ['commit']="${KOOPA_INSTALL_VERSION:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['url']='https://github.com/SpaceVim/SpaceVim.git'
        ['xdg_data_home']="$(koopa_xdg_data_home)"
    )
    # Symlink the font cache, to avoid unnecessary copy step.
    if koopa_is_macos
    then
        koopa_ln "${HOME:?}/Library/Fonts" "${dict['xdg_data_home']}/fonts"
    fi
    koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    # Bug fix for vimproc error.
    # https://github.com/SpaceVim/SpaceVim/issues/435
    dict['vimproc_prefix']="${dict['prefix']}/bundle/vimproc.vim"
    koopa_alert "Fixing vimproc at '${dict['vimproc_prefix']}'."
    (
        koopa_cd "${dict['vimproc_prefix']}"
        "${app['make']}"
    )
    return 0
}
