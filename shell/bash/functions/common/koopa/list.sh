#!/usr/bin/env bash

# FIXME IMPROVE SUPPORT FOR ANY KOOPA::LIST_* FUNCTION.
koopa::list() { # {{{1
    # """
    # List exported koopa scripts.
    # @note Updated 2020-12-03.
    # """
    local name
    name="${1:-}"
    case "$name" in
        '')
            # FIXME THIS NEEDS TO EXCLUDE 'APP' and 'OPT' BETTER.
            koopa::rscript_vanilla 'list'
            ;;
        app-versions)
            shift 1
            koopa::list_app_versions "$@"
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
