# XDG config home.
# @note Updated 2026-05-01.
export def _koopa_xdg_config_home [] -> string {
    $env | get -i XDG_CONFIG_HOME | default $"($env.HOME)/.config"
}
