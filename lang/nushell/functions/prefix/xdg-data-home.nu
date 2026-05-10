# XDG data home.
# @note Updated 2026-05-01.
export def _koopa_xdg_data_home [] -> string {
    $env | get -i XDG_DATA_HOME | default $"($env.HOME)/.local/share"
}
