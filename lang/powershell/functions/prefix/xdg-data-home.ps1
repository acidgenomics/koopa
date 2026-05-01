# XDG data home.
# @note Updated 2026-05-01.
function _koopa_xdg_data_home {
    if ($env:XDG_DATA_HOME) {
        return $env:XDG_DATA_HOME
    }
    return (Join-Path $HOME '.local/share')
}
