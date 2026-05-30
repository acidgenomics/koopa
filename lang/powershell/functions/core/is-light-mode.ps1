function _koopa_is_light_mode {
    if ($IsMacOS) {
        $style = (& /usr/bin/defaults read -g AppleInterfaceStyle 2>$null) -join ''
        return $style -ne 'Dark'
    }
    return (_koopa_terminal_is_light_background)
}
