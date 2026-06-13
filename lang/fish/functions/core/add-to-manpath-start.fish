function _koopa_add_to_manpath_start
    # Force add to MANPATH start.
    # @note Updated 2026-06-13.
    if not set -q MANPATH
        set -gx MANPATH ''
    end
    for dir in $argv
        test -d "$dir"; or continue
        if contains -- "$dir" (string split ':' "$MANPATH")
            set -l new_parts
            for part in (string split ':' "$MANPATH")
                test "$part" = "$dir"; and continue
                set -a new_parts "$part"
            end
            set -gx MANPATH (string join ':' $new_parts)
        end
        if test -z "$MANPATH"
            set -gx MANPATH "$dir"
        else
            set -gx MANPATH "$dir:$MANPATH"
        end
    end
end
