# Activate starship cross-shell prompt.
# @note Updated 2026-05-01.
fn activate-starship {
    var starship = $E:KOOPA_PREFIX'/bin/starship'
    if (not (path:is-regular &follow-symlink $starship)) {
        return
    }
    eval (e:starship init elvish)
}
