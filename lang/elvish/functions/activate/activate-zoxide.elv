# Activate zoxide.
# @note Updated 2026-05-01.
fn activate-zoxide {
    var zoxide = $E:KOOPA_PREFIX'/bin/zoxide'
    if (not (path:is-regular &follow-symlink $zoxide)) {
        return
    }
    eval (e:zoxide init elvish)
}
