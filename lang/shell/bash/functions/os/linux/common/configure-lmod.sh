#!/usr/bin/env bash

koopa::linux_configure_lmod() { # {{{1
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2022-01-28.
    # """
    local dict
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_admin
    declare -A dict=(
        [etc_dir]='/etc/profile.d'
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="$(koopa::lmod_prefix)"
    dict[init_dir]="${dict[prefix]}/apps/lmod/lmod/init"
    koopa::assert_is_dir "${dict[init_dir]}"
    if [[ ! -d "${dict[etc_dir]}" ]]
    then
        koopa::mkdir --sudo "${dict[etc_dir]}"
    fi
    # bash, zsh
    koopa::ln --sudo \
        "${dict[init_dir]}/profile" \
        "${dict[etc_dir]}/z00_lmod.sh"
    # csh, tcsh
    koopa::ln --sudo \
        "${dict[init_dir]}/cshrc" \
        "${dict[etc_dir]}/z00_lmod.csh"
    # fish
    if koopa::is_installed 'fish'
    then
        dict[fish_etc_dir]='/etc/fish/conf.d'
        koopa::alert "Updating Fish configuration in '${dict[fish_etc_dir]}'."
        if [[ ! -d "${dict[fish_etc_dir]}" ]]
        then
            koopa::mkdir --sudo "${dict[fish_etc_dir]}"
        fi
        koopa::ln --sudo \
            "${dict[init_dir]}/profile.fish" \
            "${dict[fish_etc_dir]}/z00_lmod.fish"
    fi
    return 0
}
