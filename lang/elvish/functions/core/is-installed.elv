# Are all of the requested programs installed?
# @note Updated 2026-05-01.
fn is-installed {|@cmds|
    for cmd $cmds {
        if (not (has-external $cmd)) {
            put $false
            return
        }
    }
    put $true
}
