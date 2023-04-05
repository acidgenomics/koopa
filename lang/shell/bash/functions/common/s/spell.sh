#!/usr/bin/env bash

koopa_spell() {
    # """
    # Offline spellcheck using GNU aspell.
    # @note Updated 2022-06-05.
    #
    # Returns '*' on successful match.
    #
    # @seealso
    # - https://tylercipriani.com/blog/2017/08/14/offline-spelling-with-aspell/
    #
    # @examples
    # koopa_spell 'berucracy' 'falsse' 'true'
    # """
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['aspell']="$(koopa_locate_aspell)"
        ['tail']="$(koopa_locate_tail)"
    )
    [[ -x "${app['aspell']}" ]] || exit 1
    [[ -x "${app['tail']}" ]] || exit 1
    koopa_print "$@" \
        | "${app['aspell']}" pipe \
        | "${app['tail']}" -n '+2'
    return 0
}
