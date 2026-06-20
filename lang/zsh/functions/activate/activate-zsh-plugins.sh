#!/usr/bin/env zsh

_koopa_activate_zsh_plugins() {
    local zsh_plugins_dir
    zsh_plugins_dir="${XDG_DATA_HOME:?}/zsh/plugins"
    [[ -d "$zsh_plugins_dir" ]] || return 0
    local plugin plugin_file
    for plugin in "${zsh_plugins_dir}"/*(/N:t)
    do
        plugin_file="${zsh_plugins_dir}/${plugin}/${plugin}.zsh"
        [[ -f "$plugin_file" ]] || continue
        source "$plugin_file"
    done
    return 0
}
