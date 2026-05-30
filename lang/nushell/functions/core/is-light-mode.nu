export def _koopa_is_light_mode [] {
    if (sys host | get name) == "Darwin" {
        let style = (try { ^/usr/bin/defaults read -g AppleInterfaceStyle } catch { "" })
        $style != "Dark"
    } else {
        _koopa_terminal_is_light_background
    }
}
