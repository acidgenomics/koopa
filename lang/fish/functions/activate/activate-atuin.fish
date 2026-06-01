function _koopa_activate_atuin
    set -l atuin "$KOOPA_PREFIX/bin/atuin"
    if not test -x $atuin
        return 0
    end
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/atuin-fish.fish"
    if not test -f $cache_file; or test $atuin -nt $cache_file
        mkdir -p (path dirname $cache_file)
        $atuin init fish --disable-up-arrow > $cache_file
    end
    source $cache_file
end
