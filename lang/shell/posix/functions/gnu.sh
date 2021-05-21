#!/usr/bin/env bash

__koopa_gnu_app() { # {{{1
    # """
    # GNU app.
    # @note Updated 2021-05-21.
    # """
    local brew_opt brew_prefix cmd
    brew_opt="${1:?}"
    cmd="${2:?}"
    shift 2
    koopa::assert_has_args "$#"
    if koopa::is_macos
    then
        brew_prefix="$(_koopa_homebrew_prefix)"
        # > cmd="${brew_prefix}/opt/${brew_opt}/bin/g${cmd}"
        cmd="${brew_prefix}/opt/${brew_opt}/libexec/gnubin/${cmd}"
    fi
    if [ ! -x "$cmd" ]
    then
        _koopa_warning "Missing GNU app: '${cmd}'."
        return 1
    fi
    "$cmd" "$@"
    return 0
}

_koopa_gnu_find() { # {{{1
    # """
    # GNU tr.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'findutils' 'find' "$@"
    return 0
}

_koopa_gnu_tr() { # {{{1
    # """
    # GNU tr.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'tr' "$@"
    return 0
}

_koopa_gnu_uname() { # {{{1
    # """
    # GNU uname.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'uname' "$@"
    return 0
}

_koopa_gnu_wc() { # {{{1
    # """
    # GNU wc.
    # @note Updated 2021-05-21.
    # """
    __koopa_gnu_app 'coreutils' 'wc' "$@"
    return 0
}
