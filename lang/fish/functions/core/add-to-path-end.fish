function _koopa_add_to_path_end
    # Force add to PATH end.
    # @note Updated 2026-05-01.
    for dir in $argv
        test -d "$dir"; or continue
        if contains -- "$dir" $PATH
            set -l idx (contains -i -- "$dir" $PATH)
            set -e PATH[$idx]
        end
        set -gx PATH $PATH "$dir"
    end
end
