function _koopa_is_light_mode
    if _koopa_is_macos
        set -l cache_file "$HOME/.cache/koopa/color-mode"
        if test -f "$cache_file"
            set -l mode (string trim < "$cache_file")
            test "$mode" = light
        else
            test (/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null) != Dark
        end
    else if set -q TMUX
        or string match -q 'screen*' -- "$TERM"
        or string match -q 'tmux*' -- "$TERM"
        set -l cache_file "$HOME/.cache/koopa/color-mode"
        test -f "$cache_file"; and test (string trim < "$cache_file") = light
    else if test "$TERM_PROGRAM" = vscode
        set -l cache_file "$HOME/.cache/koopa/color-mode"
        test -f "$cache_file"; and test (string trim < "$cache_file") = light
    else if set -q SSH_CONNECTION; or set -q SSH_TTY
        set -l cache_file "$HOME/.cache/koopa/color-mode"
        test -f "$cache_file"; and test (string trim < "$cache_file") = light
    else
        _koopa_terminal_is_light_background
    end
end
