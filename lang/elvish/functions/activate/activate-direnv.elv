# Activate direnv.
# @note Updated 2026-05-01.
fn activate-direnv {
    var direnv = $E:KOOPA_PREFIX'/bin/direnv'
    if (not (path:is-regular &follow-symlink $direnv)) {
        return
    }
    eval (e:direnv hook elvish)
}
