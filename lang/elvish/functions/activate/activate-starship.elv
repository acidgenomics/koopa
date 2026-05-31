# Activate starship cross-shell prompt.
# @note Updated 2026-05-31.
fn activate-starship {
    var starship = $E:KOOPA_PREFIX'/bin/starship'
    if (not (path:is-regular &follow-symlink $starship)) {
        return
    }
    var cache-file = $E:XDG_CACHE_HOME'/koopa/shell-init/starship-elvish.elv'
    if (or (not (path:is-regular $cache-file)) (path:is-newer $starship $cache-file)) {
        mkdir -p (path:dir $cache-file)
        e:starship init elvish > $cache-file
    }
    eval (slurp < $cache-file)
}
