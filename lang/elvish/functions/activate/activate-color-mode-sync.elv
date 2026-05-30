# Activate color mode sync hook.
# @note Updated 2026-05-30.
fn activate-color-mode-sync {
    set edit:before-readline = (conj $edit:before-readline {
        var new-mode = (if (is-light-mode) { put 'light' } else { put 'dark' })
        if (not (eq $new-mode (get-env KOOPA_COLOR_MODE))) {
            set-env KOOPA_COLOR_MODE $new-mode
            printf "%b\n" "Terminal appearance changed to "$new-mode" mode. Updating shell colors." >&2
            unset-env FZF_DEFAULT_OPTS
            activate-fzf
        }
    })
}
