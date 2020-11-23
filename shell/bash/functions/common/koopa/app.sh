#!/usr/bin/env bash

koopa::app() { # {{{1
    # """
    # Application commands.
    # @note Updated 2020-11-23.
    # """
    local name
    name="${1:-}"
    case "$name" in
        clean)
            name='delete_broken_app_symlinks'
            ;;
        list)
            name='list_app_versions'
            ;;
        link)
            name='link_app'
            ;;
        prune)
            name='prune_apps'
            ;;
        unlink)
            name='unlink_app'
            ;;
    esac
    koopa::_run_function "$name"
    return 0
}
