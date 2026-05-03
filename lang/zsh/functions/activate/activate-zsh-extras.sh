#!/usr/bin/env zsh

_koopa_activate_zsh_extras() {
    _koopa_is_interactive || return 0
    _koopa_activate_zsh_fpath
    _koopa_activate_zsh_compinit
    _koopa_activate_zsh_bashcompinit
    _koopa_activate_zsh_colors
    _koopa_activate_zsh_editor
    _koopa_activate_zsh_plugins
    _koopa_activate_zsh_aliases
    _koopa_activate_zsh_prompt
    _koopa_activate_zsh_reverse_search
    _koopa_activate_zsh_completion
    return 0
}
