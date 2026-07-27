export def _koopa_is_light_mode [] {
    if (sys host | get name) == "Darwin" {
        let style = (try { ^/usr/bin/defaults read -g AppleInterfaceStyle } catch { "" })
        $style != "Dark"
    } else if ($env.TMUX? != null) or ($env.TERM? | default "" | str starts-with "screen") or ($env.TERM? | default "" | str starts-with "tmux") {
        let cache_file = ($env.HOME | path join ".cache" "koopa" "color-mode")
        if ($cache_file | path exists) {
            (open $cache_file | str trim) == "light"
        } else {
            false
        }
    } else if ($env.SSH_CONNECTION? != null) or ($env.SSH_TTY? != null) {
        let cache_file = ($env.HOME | path join ".cache" "koopa" "color-mode")
        if ($cache_file | path exists) {
            (open $cache_file | str trim) == "light"
        } else {
            false
        }
    } else {
        _koopa_terminal_is_light_background
    }
}
