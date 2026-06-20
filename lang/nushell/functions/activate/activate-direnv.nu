# Activate direnv.
# @note Updated 2026-05-01.
#
# Nushell direnv integration requires the hook to be configured in
# config.nu. This function sets up the environment and provides guidance.
#
# To complete direnv setup, add this to your config.nu:
#     $env.config = ($env.config | upsert hooks {
#         pre_prompt: [{ ||
#             if (which direnv | is-not-empty) {
#                 direnv export json | from json | default {} | load-env
#             }
#         }]
#     })
export def _koopa_activate_direnv [] {
    let direnv = $"($env.KOOPA_PREFIX)/bin/direnv"
    if not ($direnv | path exists) {
        return
    }
    # Clear stale direnv values.
    hide-env -i DIRENV_DIFF
    hide-env -i DIRENV_DIR
    hide-env -i DIRENV_FILE
    hide-env -i DIRENV_WATCHES
}
