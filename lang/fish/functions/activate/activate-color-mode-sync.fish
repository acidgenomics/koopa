function _koopa_activate_color_mode_sync
    # Activate color mode sync hook.
    # @note Updated 2026-06-14.
    _koopa_is_interactive; or return 0
    function _koopa_fish_color_mode_sync --on-event fish_postexec
        set -l new_mode
        if _koopa_is_light_mode
            set new_mode light
        else
            set new_mode dark
        end
        test "$new_mode" != "$KOOPA_COLOR_MODE"; or return 0
        set -gx KOOPA_COLOR_MODE "$new_mode"
        printf '%b\n' "Terminal appearance changed to $new_mode mode. Updating shell colors." >&2
        set -e FZF_DEFAULT_OPTS
        _koopa_activate_fzf
        _koopa_activate_difftastic
        _koopa_activate_dircolors
        set -l _palette
        if test "$new_mode" = light
            set _palette (test -n "$XDG_CONFIG_HOME" && echo "$XDG_CONFIG_HOME" || echo "$HOME/.config")/fish/dracula-pro-alucard-colors.fish
        else
            set _palette (test -n "$XDG_CONFIG_HOME" && echo "$XDG_CONFIG_HOME" || echo "$HOME/.config")/fish/dracula-pro-colors.fish
        end
        test -f "$_palette"; and source "$_palette"
    end
end
