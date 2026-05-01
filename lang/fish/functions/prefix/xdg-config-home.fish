function _koopa_xdg_config_home
    # XDG config home.
    # @note Updated 2026-05-01.
    if set -q XDG_CONFIG_HOME
        echo "$XDG_CONFIG_HOME"
    else
        echo "$HOME/.config"
    end
end
