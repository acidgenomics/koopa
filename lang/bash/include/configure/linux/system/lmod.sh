#!/usr/bin/env bash

main() {
    # """
    # Link lmod configuration files in '/etc/profile.d/'.
    # @note Updated 2023-05-14.
    #
    # Lmod activation is disabled by default for root user. Can override with
    # 'LMOD_ALLOW_ROOT_USE' environment variable in profile activation.
    # """
    local -A dict
    koopa_assert_has_args_le "$#" 1
    dict['etc_dir']='/etc/profile.d'
    dict['prefix']="${1:-}"
    if [[ -z "${dict['prefix']}" ]]
    then
        dict['prefix']="$(koopa_app_prefix 'lmod')"
    fi
    koopa_assert_is_dir "${dict['prefix']}"
    dict['init_dir']="${dict['prefix']}/apps/lmod/lmod/init"
    koopa_assert_is_dir "${dict['init_dir']}"
    if [[ ! -d "${dict['etc_dir']}" ]]
    then
        koopa_mkdir --sudo "${dict['etc_dir']}"
    fi
    # bash, zsh.
    koopa_ln --sudo \
        "${dict['init_dir']}/profile" \
        "${dict['etc_dir']}/z00_lmod.sh"
    # csh, tcsh.
    koopa_ln --sudo \
        "${dict['init_dir']}/cshrc" \
        "${dict['etc_dir']}/z00_lmod.csh"
    # fish.
    dict['fish_etc_dir']='/etc/fish/conf.d'
    if [[ ! -d "${dict['fish_etc_dir']}" ]]
    then
        koopa_mkdir --sudo "${dict['fish_etc_dir']}"
    fi
    koopa_ln --sudo \
        "${dict['init_dir']}/profile.fish" \
        "${dict['fish_etc_dir']}/z00_lmod.fish"
    return 0
}
