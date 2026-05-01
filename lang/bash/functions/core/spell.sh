#!/usr/bin/env bash

_koopa_spell() {
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
    # _koopa_spell 'berucracy' 'falsse' 'true'
    # """
    local -A app
    _koopa_assert_has_args "$#"
    app['aspell']="$(_koopa_locate_aspell)"
    app['tail']="$(_koopa_locate_tail)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_print "$@" \
        | "${app['aspell']}" pipe \
        | "${app['tail']}" -n '+2'
    return 0
}
