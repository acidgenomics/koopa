#!/usr/bin/env zsh

_koopa_activate_color_mode_sync() {
    _koopa_is_interactive || return 0
    _koopa_zsh_color_mode_sync() {
        local new_mode
        if _koopa_is_light_mode
        then
            new_mode='light'
        else
            new_mode='dark'
        fi
        [[ "${KOOPA_COLOR_MODE:-}" != "$new_mode" ]] || return 0
        export KOOPA_COLOR_MODE="$new_mode"
        __koopa_warn "Terminal appearance changed to ${new_mode} mode. Updating shell colors."
        unset -v FZF_DEFAULT_OPTS
        _koopa_activate_fzf
        _koopa_activate_dircolors
        _koopa_activate_difftastic
        _koopa_activate_mcfly_colors
        local _palette
        if [[ "$new_mode" == 'light' ]]
        then
            _palette="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/dracula-pro-alucard-colors.zsh"
        else
            _palette="${XDG_CONFIG_HOME:-${HOME}/.config}/zsh/dracula-pro-colors.zsh"
        fi
        # Re-source the palette to update ZSH_HIGHLIGHT_STYLES and
        # ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE in the live shell.  Both plugins pick
        # up the new values on the next line edit / suggestion.  This is a fork-
        # free local source; the free-Dracula inline fallback (Pro not installed)
        # requires a new shell — acceptable since Pro is the target environment.
        [[ -f "$_palette" ]] && source "$_palette"
        return 0
    }
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _koopa_zsh_color_mode_sync
    return 0
}
