#!/usr/bin/env bash

koopa::cellar() { # {{{1
    # """
    # Cellar commands.
    # @note Updated 2020-11-18.
    # """
    local name
    name="${1:-}"
    case "$name" in
        clean)
            name='delete_broken_symlinks'
            ;;
        list)
            name='list_cellar_versions'
            ;;
        link)
            name='link_cellar'
            ;;
        prune)
            name='prune_cellar'
            ;;
        unlink)
            name='unlink_cellar'
            ;;
    esac
    koopa::_run_function "$name"
    return 0
}
