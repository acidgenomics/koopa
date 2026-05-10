function _koopa_activate_fish_extras
    # Activate fish-specific extras.
    # @note Updated 2026-05-03.
    _koopa_is_interactive; or return 0
    # Suppress the default fish greeting.
    set -g fish_greeting
    # Add koopa completions to fish completion path.
    if test -d "$KOOPA_PREFIX/share/fish/vendor_completions.d"
        if not contains -- "$KOOPA_PREFIX/share/fish/vendor_completions.d" \
            $fish_complete_path
            set -gx fish_complete_path \
                $fish_complete_path \
                "$KOOPA_PREFIX/share/fish/vendor_completions.d"
        end
    end
end
