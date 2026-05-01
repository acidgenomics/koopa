#!/usr/bin/env bash

main() {
    # """
    # Install SpaceVim.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - https://spacevim.org
    # - https://spacevim.org/quick-start-guide/
    # - https://spacevim.org/faq/
    # """
    local -A app dict
    app['make']="$(_koopa_locate_make)"
    _koopa_assert_is_executable "${app[@]}"
    dict['commit']="${KOOPA_INSTALL_VERSION:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']='https://gitlab.com/SpaceVim/SpaceVim.git'
    dict['xdg_data_home']="$(_koopa_xdg_data_home)"
    # Symlink the font cache, to avoid unnecessary copy step.
    if _koopa_is_macos
    then
        _koopa_ln \
            "${HOME:?}/Library/Fonts" \
            "${dict['xdg_data_home']}/fonts"
    fi
    _koopa_git_clone \
        --commit="${dict['commit']}" \
        --prefix="${dict['prefix']}" \
        --url="${dict['url']}"
    # Bug fix for vimproc error.
    # https://github.com/SpaceVim/SpaceVim/issues/435
    dict['vimproc_prefix']="${dict['prefix']}/bundle/vimproc.vim"
    _koopa_alert "Fixing vimproc at '${dict['vimproc_prefix']}'."
    (
        _koopa_cd "${dict['vimproc_prefix']}"
        "${app['make']}"
    )
    return 0
}
