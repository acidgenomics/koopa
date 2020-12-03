#!/usr/bin/env bash

# FIXME NEED TO SUPPORT:
# path-priority
# dotfiles

koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-08-12.
    # """
    local name
    name="${1:-}"
    case "$name" in
        '')
            koopa::rscript_vanilla 'list'
            ;;
        dotfiles)
            shift 1
            koopa::list_dotfiles "$@"
            ;;
        path-priority)
            shift 1
            koopa::list_path_priority "$@"
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    return 0
}
