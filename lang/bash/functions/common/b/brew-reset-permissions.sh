#!/usr/bin/env bash

koopa_brew_reset_permissions() {
    # """
    # Reset permissions on Homebrew installation.
    # @note Updated 2023-05-20.
    #
    # Homebrew currently installs to isolated linuxbrew user on Linux.
    # """
    local -A bool dict
    local -a dirs
    local dir
    koopa_assert_has_no_args "$#"
    koopa_is_linux && return 0
    bool['reset']=0
    dict['group_name']="$(koopa_admin_group_name)"
    dict['prefix']="$(koopa_homebrew_prefix)"
    dict['user_id']="$(koopa_user_id)"
    dict['user_name']="$(koopa_user_name)"
    koopa_alert 'Checking permissions.'
    koopa_assert_is_dir "${dict['prefix']}/Cellar"
    dict['stat_user_id']="$(koopa_stat_user_id "${dict['prefix']}/Cellar")"
    if [[ "${dict['stat_user_id']}" != "${dict['user_id']}" ]]
    then
        koopa_stop "Homebrew is not owned by current user \
('${dict['user_name']}')."
    fi
    dirs=(
        "${dict['prefix']}/bin"
        "${dict['prefix']}/etc"
        "${dict['prefix']}/etc/bash_completion.d"
        "${dict['prefix']}/include"
        "${dict['prefix']}/lib"
        "${dict['prefix']}/lib/pkgconfig"
        "${dict['prefix']}/sbin"
        "${dict['prefix']}/share"
        "${dict['prefix']}/share/doc"
        "${dict['prefix']}/share/info"
        "${dict['prefix']}/share/locale"
        "${dict['prefix']}/share/man"
        "${dict['prefix']}/share/man/man1"
        "${dict['prefix']}/share/man/man3"
        "${dict['prefix']}/share/man/man5"
        "${dict['prefix']}/share/zsh"
        "${dict['prefix']}/share/zsh/site-functions"
        "${dict['prefix']}/var/homebrew/linked"
        "${dict['prefix']}/var/homebrew/locks"
    )
    for dir in "${dirs[@]}"
    do
        [[ "${bool['reset']}" -eq 1 ]] && continue
        [[ -d "$dir" ]] || continue
        [[ "$(koopa_stat_user_id "$dir")" == "${dict['user_id']}" ]] \
            && continue
        bool['reset']=1
    done
    bool['reset']=0 && return 0
    koopa_alert "Resetting ownership of files in \
'${dict['prefix']}' to '${dict['user_name']}:${dict['group_name']}'."
    koopa_chown \
        --no-dereference \
        --recursive \
        --sudo \
        "${dict['user_name']}:${dict['group_name']}" \
        "${dict['prefix']}/"*
    return 0
}
