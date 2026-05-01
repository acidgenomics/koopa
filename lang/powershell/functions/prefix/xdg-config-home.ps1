# XDG config home.
# @note Updated 2026-05-01.
function _koopa_xdg_config_home {
    if ($env:XDG_CONFIG_HOME) {
        return $env:XDG_CONFIG_HOME
    }
    return (Join-Path $HOME '.config')
}
