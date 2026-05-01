# Are all of the requested programs installed?
# @note Updated 2026-05-01.
export def _koopa_is_installed [...cmds: string] -> bool {
    for cmd in $cmds {
        if (which $cmd | is-empty) {
            return false
        }
    }
    true
}
