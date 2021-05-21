#!/usr/bin/env bash

koopa:::gnu_app() { # {{{1
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
        brew_prefix="$(koopa::homebrew_prefix)"
        # > cmd="${brew_prefix}/opt/${brew_opt}/bin/g${cmd}"
        cmd="${brew_prefix}/opt/${brew_opt}/libexec/gnubin/${cmd}"
    fi
    koopa::assert_is_gnu "$cmd"
    "$cmd" "$@"
    return 0
}

koopa::gnu_find() { # {{{1
    # """
    # GNU tr.
    # @note Updated 2021-05-21.
    # """
    koopa:::gnu_app 'findutils' 'find' "$@"
    return 0
}

koopa::gnu_tr() { # {{{1
    # """
    # GNU tr.
    # @note Updated 2021-05-21.
    # """
    koopa:::gnu_app 'coreutils' 'tr' "$@"
    return 0
}

koopa::gnu_uname() { # {{{1
    # """
    # GNU uname.
    # @note Updated 2021-05-21.
    # """
    koopa:::gnu_app 'coreutils' 'uname' "$@"
    return 0
}
