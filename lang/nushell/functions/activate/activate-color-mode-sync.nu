# Activate color mode sync hook.
# @note Updated 2026-05-31.
#
# Registers a pre-prompt hook that detects terminal appearance changes and
# updates KOOPA_COLOR_MODE, FZF_DEFAULT_OPTS, and DFT_BACKGROUND accordingly.
export def _koopa_activate_color_mode_sync [] {
    $env.config = ($env.config | upsert hooks.pre_prompt (
        ($env.config | get -i hooks.pre_prompt | default []) | append { ||
            let new_mode = if (_koopa_is_light_mode) { "light" } else { "dark" }
            if $new_mode != ($env | get -i KOOPA_COLOR_MODE | default "") {
                $env.KOOPA_COLOR_MODE = $new_mode
                print -e $"Terminal appearance changed to ($new_mode) mode. Updating shell colors."
                $env.FZF_DEFAULT_OPTS = $"--border --color ($new_mode) --multi"
                $env.DFT_BACKGROUND = $new_mode
            }
        }
    ))
}
