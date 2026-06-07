function _koopa_activate_television
    set -l tv "$KOOPA_PREFIX/bin/tv"
    if not test -x $tv
        return 0
    end
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/television-fish.fish"
    if not test -f $cache_file; or test $tv -nt $cache_file
        mkdir -p (path dirname $cache_file)
        $tv init fish > $cache_file
    end
    source $cache_file
end
