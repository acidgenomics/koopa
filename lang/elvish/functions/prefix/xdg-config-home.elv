# XDG config home.
# @note Updated 2026-05-01.
fn xdg-config-home {
    if (has-env XDG_CONFIG_HOME) {
        put $E:XDG_CONFIG_HOME
    } else {
        put $E:HOME'/.config'
    }
}
