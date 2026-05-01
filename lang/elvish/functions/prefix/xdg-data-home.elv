# XDG data home.
# @note Updated 2026-05-01.
fn xdg-data-home {
    if (has-env XDG_DATA_HOME) {
        put $E:XDG_DATA_HOME
    } else {
        put $E:HOME'/.local/share'
    }
}
