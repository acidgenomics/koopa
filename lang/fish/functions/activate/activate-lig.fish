function _koopa_activate_lig_part
    set -l part $argv[1]
    set -l lig "$KOOPA_PREFIX/bin/lig"
    test -x "$lig"; or return 0
    status is-interactive; or return 0
    set -q LIG_DISABLE; and test -n "$LIG_DISABLE"; and return 0
    set -l cache_file "$XDG_CACHE_HOME/koopa/shell-init/lig-fish-$part.fish"
    if not test -s "$cache_file"; or test "$lig" -nt "$cache_file"
        set -l cache_dir (path dirname "$cache_file")
        command mkdir -p "$cache_dir"; or return 1
        set -l tmp_file "$cache_file.$fish_pid"
        if not "$lig" init fish "$part" > "$tmp_file"
            command rm -f "$tmp_file"
            return 1
        end
        if not test -s "$tmp_file"; or not command mv -f "$tmp_file" "$cache_file"
            command rm -f "$tmp_file"
            return 1
        end
    end
    source "$cache_file"
end

function _koopa_activate_lig_pre
    _koopa_activate_lig_part pre
end

function _koopa_activate_lig_post
    _koopa_activate_lig_part post
end
