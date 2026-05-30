function _koopa_is_light_mode
    if _koopa_is_macos
        test (/usr/bin/defaults read -g AppleInterfaceStyle 2>/dev/null) != Dark
    else
        _koopa_terminal_is_light_background
    end
end
