function _koopa_xdg_data_home
    # XDG data home.
    # @note Updated 2026-05-01.
    if set -q XDG_DATA_HOME
        echo "$XDG_DATA_HOME"
    else
        echo "$HOME/.local/share"
    end
end
