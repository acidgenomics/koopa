#!/usr/bin/env zsh

_koopa_activate_copilot_cli() {
    [[ -x "${KOOPA_PREFIX:?}/bin/copilot" ]] || return 0
    export COPILOT_AUTO_UPDATE=false
    _koopa_is_interactive || return 0
    copilot() {
        if [[ -n "${KOOPA_BUCKET:-}" ]] && [[ -d "${KOOPA_BUCKET}/.obsidian" ]]
        then
            command copilot --add-dir "$KOOPA_BUCKET" "$@"
        else
            command copilot "$@"
        fi
    }
    return 0
}
