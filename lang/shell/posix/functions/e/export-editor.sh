#!/bin/sh

koopa_export_editor() {
    # """
    # Export 'EDITOR' variable.
    # @note Updated 2022-05-12.
    # """
    if [ -z "${EDITOR:-}" ]
    then
        EDITOR="$(koopa_bin_prefix)/vim"
    fi
    VISUAL="$EDITOR"
    export EDITOR VISUAL
    return 0
}
