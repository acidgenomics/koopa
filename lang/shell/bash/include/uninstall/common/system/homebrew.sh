#!/usr/bin/env bash

main() {
    # """
    # Uninstall Homebrew.
    # @note Updated 2023-03-24.
    #
    # Important! Homebrew uninstaller will currently attempt to delete the
    # parent directory containing 'brew', so make sure we remove our symlink
    # in koopa first.
    #
    # @seealso
    # - https://docs.brew.sh/FAQ
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    if [[ ! -x "$(koopa_locate_brew --allow-missing)" ]]
    then
        koopa_stop 'Homebrew is not installed.'
    fi
    dict['user']="$(koopa_user_name)"
    dict['file']='uninstall.sh'
    dict['url']="https://raw.githubusercontent.com/Homebrew/install/\
master/${dict['file']}"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_chmod 'u+x' "${dict['file']}"
    NONINTERACTIVE=1 "./${dict['file']}" || true
    if koopa_is_linux
    then
        if [[ -d '/home/linuxbrew' ]]
        then
            koopa_rm --sudo '/home/linuxbrew'
        fi
    fi
    return 0
}
