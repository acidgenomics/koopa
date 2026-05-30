function _koopa_is_light_mode
    if _koopa_is_macos
        set -l cache_file "$HOME/.cache/koopa/color-mode"
        if test -f "$cache_file"
            set -l mode (string trim < "$cache_file")
            test "$mode" = light
        else
            test (/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null) != Dark
        end
    else
        _koopa_terminal_is_light_background
    end
end
