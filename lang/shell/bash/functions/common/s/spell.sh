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
    local -A app
    koopa_assert_has_args "$#"
    app['aspell']="$(koopa_locate_aspell)"
    app['tail']="$(koopa_locate_tail)"
    koopa_assert_is_executable "${app[@]}"
    koopa_print "$@" \
        | "${app['aspell']}" pipe \
        | "${app['tail']}" -n '+2'
    return 0
}
