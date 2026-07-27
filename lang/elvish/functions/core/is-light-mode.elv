fn is-light-mode {
    if (eq $platform:os 'darwin') {
        var cache-file = $E:HOME'/.cache/koopa/color-mode'
        if (path:is-regular $cache-file) {
            var mode = (str:trim-space (slurp < $cache-file))
            eq $mode 'light'
        } else {
            var style = ''
            try {
                set style = (str:trim-space (/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null))
            } catch { }
            not (eq $style 'Dark')
        }
    } elif (or (has-env TMUX) (str:has-prefix (get-env TERM) 'screen') (str:has-prefix (get-env TERM) 'tmux')) {
        var cache-file = $E:HOME'/.cache/koopa/color-mode'
        if (path:is-regular $cache-file) {
            eq (str:trim-space (slurp < $cache-file)) 'light'
        } else {
            put $false
        }
    } elif (or (has-env SSH_CONNECTION) (has-env SSH_TTY)) {
        var cache-file = $E:HOME'/.cache/koopa/color-mode'
        if (path:is-regular $cache-file) {
            eq (str:trim-space (slurp < $cache-file)) 'light'
        } else {
            put $false
        }
    } else {
        terminal-is-light-background
    }
}
