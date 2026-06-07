function _koopa_activate_mise
    set -l mise "$KOOPA_PREFIX/bin/mise"
    if not test -x $mise
        return 0
    end
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/mise-fish.fish"
    if not test -f $cache_file; or test $mise -nt $cache_file
        mkdir -p (path dirname $cache_file)
        $mise activate fish > $cache_file
    end
    source $cache_file
end
