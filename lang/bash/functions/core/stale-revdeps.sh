#!/usr/bin/env bash

_koopa_stale_revdeps() {
    # """
    # Get installed apps with stale runtime dependencies.
    # @note Updated 2026-05-01.
    #
    # @examples
    # _koopa_stale_revdeps 'curl' 'openssl'
    # """
    _koopa_assert_has_args "$#"
    _koopa_python_script 'stale-revdeps.py' "$@"
    return 0
}
