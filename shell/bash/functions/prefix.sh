#!/usr/bin/env bash

koopa::r_prefix() { # {{{1
    # """
    # R prefix.
    # @note Updated 2020-07-05.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    local prefix r rscript
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
    prefix="$( \
        "$rscript" \
            --vanilla \
            -e 'cat(normalizePath(Sys.getenv("R_HOME")))' \
        2>/dev/null \
    )"
    [[ -d "$prefix" ]] || return 1
    koopa::print "$prefix"
    return 0
}

koopa::r_library_prefix() { # {{{1
    # """
    # R default library prefix.
    # @note Updated 2020-07-05.
    # """
    local prefix r rscript
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
    prefix="$("$rscript" -e 'cat(normalizePath(.libPaths()[[1L]]))')"
    [[ -d "$prefix" ]] || return 1
    koopa::print "$prefix"
    return 0
}

koopa::r_system_library_prefix() { # {{{1
    # """
    # R system library prefix.
    # @note Updated 2020-07-05.
    # """
    local prefix r rscript
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
    prefix="$( \
        "$rscript" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    [[ -d "$prefix" ]] || return 1
    koopa::print "$prefix"
    return 0
}
