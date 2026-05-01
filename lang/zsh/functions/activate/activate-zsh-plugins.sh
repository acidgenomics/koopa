#!/usr/bin/env zsh

_koopa_activate_zsh_plugins() {
    local plugin plugins zsh_plugins_dir
    zsh_plugins_dir="$(_koopa_xdg_data_home)/zsh/plugins"
    [[ -d "$zsh_plugins_dir" ]] || return 0
    plugins=("${(@f)$( \
        find "$zsh_plugins_dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type 'd' \
        | sort \
        | xargs basename \
    )}")
    for plugin in "${plugins[@]}"
    do
        source "${zsh_plugins_dir}/${plugin}/${plugin}.zsh"
    done
    return 0
}
