#!/usr/bin/env zsh

_koopa_activate_zsh_editor() {
    case "${EDITOR:-}" in
        'emacs')
            bindkey -e
            ;;
        'vi' | \
        'vim')
            bindkey -v
            ;;
    esac
    return 0
}
