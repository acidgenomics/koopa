function _koopa_activate_fish_extras
    # Activate fish-specific extras.
    # @note Updated 2026-05-01.
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
    # Add app-specific fish completions.
    for app_comp in $KOOPA_PREFIX/app/*/libexec/share/fish/vendor_completions.d
        if test -d "$app_comp"
            if not contains -- "$app_comp" $fish_complete_path
                set -gx fish_complete_path $fish_complete_path "$app_comp"
            end
        end
    end
end
