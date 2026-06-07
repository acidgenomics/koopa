# Activate zoxide.
# @note Updated 2026-05-31.
fn activate-zoxide {
    var zoxide = $E:KOOPA_PREFIX'/bin/zoxide'
    if (not (path:is-regular &follow-symlink $zoxide)) {
        return
    }
    var cache-file = $E:XDG_CACHE_HOME'/koopa/shell-init/zoxide-elvish.elv'
    if (or (not (path:is-regular $cache-file)) (path:is-newer $zoxide $cache-file)) {
        mkdir -p (path:dir $cache-file)
        e:zoxide init elvish > $cache-file
    }
    eval (slurp < $cache-file)
}
