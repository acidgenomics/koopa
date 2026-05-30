fn is-light-mode {
    if (eq $platform:os 'darwin') {
        var style = ''
        try {
            set style = (str:trim-space (/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null))
        } catch { }
        not (eq $style 'Dark')
    } else {
        terminal-is-light-background
    }
}
