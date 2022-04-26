#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Doom Emacs.
    # @note Updated 2022-02-01.
    #
    # Installer flags:
    # https://github.com/hlissner/doom-emacs/blob/develop/core/cli/install.el
    #
    # Useful doom commands:
    # - doctor
    # - upgrade
    #
    # All the fonts (skipped with '--no-fonts' flag below):
    # - all-the-icons.ttf
    # - file-icons.ttf
    # - fontawesome.ttf
    # - material-design-icons.ttf
    # - octicons.ttf
    # - weathericons.ttf
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [emacs]="$(koopa_locate_emacs)"
    )
    declare -A dict=(
        [branch]='master'
        [opt_prefix]="$(koopa_opt_prefix)"
        [prefix]="${INSTALL_PREFIX:?}"
        [url]='https://github.com/hlissner/doom-emacs.git'
    )
    if [[ ! -d "${dict[opt_prefix]}/chemacs" ]]
    then
        koopa_stop 'Install chemacs first.'
    fi
    koopa_add_to_path_start "$(koopa_dirname "${app[emacs]}")"
    koopa_git_clone \
        --branch="${dict[branch]}" \
        "${dict[url]}" \
        "${dict[prefix]}"
    app[doom]="${dict[prefix]}/bin/doom"
    koopa_assert_is_installed "${app[doom]}"
    install_args=(
        # > '--no-config'
        # > '--no-install'
        '--no-env'
        '--no-fonts'
    )
    "${app[doom]}" --yes install "${install_args[@]}"
    "${app[doom]}" --yes sync
    # > "${app[doom]}" --yes doctor
    return 0
}
