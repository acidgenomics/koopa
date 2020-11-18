#!/usr/bin/env bash

koopa::cellar() { # {{{1
    # """
    # Cellar commands.
    # @note Updated 2020-11-17.
    # """
    local f fun
    case "$1" in
        clean)
            f='delete_broken_symlinks'
            shift 1
            ;;
        list)
            f='list_cellar_versions'
            shift 1
            ;;
        link)
            f='link_cellar'
            shift 1
            ;;
        unlink)
            f='unlink_cellar'
            shift 1
            ;;
        *)
            koopa::invalid_arg "$*"
            ;;
    esac
    fun="koopa::${f//-/_}"
    if ! koopa::is_function "$fun"
    then
        koopa::invalid_arg "$*"
    fi
    "$fun" "$@"
    return 0
}
