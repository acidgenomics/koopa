# Activate color mode sync hook.
# @note Updated 2026-05-31.
fn activate-color-mode-sync {
    set edit:before-readline = (conj $edit:before-readline {
        var new-mode = (if (is-light-mode) { put 'light' } else { put 'dark' })
        if (not (eq $new-mode (get-env KOOPA_COLOR_MODE))) {
            set-env KOOPA_COLOR_MODE $new-mode
            printf "%b\n" "Terminal appearance changed to "$new-mode" mode. Updating shell colors." >&2
            unset-env FZF_DEFAULT_OPTS
            activate-fzf
            activate-difftastic
            # File-driven re-render trigger (starship/bat/delta toml).
            # Backgrounded via sh -c, marker + sentinel guarded; mirrors
            # bash _koopa_activate_color_mode.
            if (not (has-env KOOPA_COLOR_MODE_SYNCING)) {
                var applied = $E:HOME'/.cache/koopa/color-mode-applied'
                var cur = ''
                if (path:is-regular $applied) {
                    set cur = (str:trim-space (slurp < $applied))
                }
                if (not (eq $cur $new-mode)) {
                    sh -c $E:KOOPA_PREFIX'/bin/koopa configure user color-mode >/dev/null 2>&1 &'
                }
            }
        }
    })
}
