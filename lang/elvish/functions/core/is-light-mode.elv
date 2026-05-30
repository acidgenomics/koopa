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
    } else {
        terminal-is-light-background
    }
}
