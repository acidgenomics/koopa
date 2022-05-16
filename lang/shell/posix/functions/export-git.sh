#!/bin/sh

koopa_export_git() {
    # """
    # Export git configuration.
    # @note Updated 2021-05-14.
    #
    # @seealso
    # https://git-scm.com/docs/merge-options
    # """
    if [ -z "${GIT_MERGE_AUTOEDIT:-}" ]
    then
        GIT_MERGE_AUTOEDIT='no'
    fi
    export GIT_MERGE_AUTOEDIT
    return 0
}
