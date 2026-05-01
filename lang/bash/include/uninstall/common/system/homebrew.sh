#!/usr/bin/env bash

# FIXME Prompt the user to continue when interactive, as this is destructive.

main() {
    # """
    # Uninstall Homebrew.
    # @note Updated 2025-01-11.
    #
    # Important! Homebrew uninstaller will currently attempt to delete the
    # parent directory containing 'brew', so make sure we remove our symlink
    # in koopa first.
    #
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local -A dict
    if [[ ! -x "$(_koopa_locate_brew --allow-missing)" ]]
    then
        _koopa_stop 'Homebrew is not installed.'
    fi
    dict['user']="$(_koopa_user_name)"
    dict['file']='uninstall.sh'
    dict['url']="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict['file']}"
    _koopa_download "${dict['url']}" "${dict['file']}"
    _koopa_chmod 'u+x' "${dict['file']}"
    NONINTERACTIVE=1 "./${dict['file']}" || true
    if _koopa_is_linux
    then
        if [[ -d '/home/linuxbrew' ]]
        then
            _koopa_rm --sudo '/home/linuxbrew'
        fi
    fi
    return 0
}
