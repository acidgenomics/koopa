# Activate direnv.
# @note Updated 2026-05-31.
fn activate-direnv {
    var direnv = $E:KOOPA_PREFIX'/bin/direnv'
    if (not (path:is-regular &follow-symlink $direnv)) {
        return
    }
    var cache-file = $E:XDG_CACHE_HOME'/koopa/shell-init/direnv-hook-elvish.elv'
    if (or (not (path:is-regular $cache-file)) ^
           (not (has-external test)) ^
           (bool ?(e:test $direnv -nt $cache-file))) {
        mkdir -p (path:dir $cache-file)
        e:direnv hook elvish > $cache-file
    }
    eval (slurp < $cache-file)
}
