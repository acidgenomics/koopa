#!/usr/bin/env bash

koopa::python_system_packages_prefix() { # {{{1
    # """
    # Python system site packages library prefix.
    # @note Updated 2021-05-25.
    # """
    local python x
    python="${1:-}"
    [[ -z "$python" ]] && python="$(koopa::locate_python)"
    koopa::assert_is_installed "$python"
    x="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    koopa::print "$x"
    return 0
}

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

koopa::r_script_prefix() { # {{{1
    # """
    # Rscript file prefix.
    # @note Updated 2020-11-17.
    # """
    koopa::print "$(koopa::koopa_prefix)/lang/r/include"
    return 0
}
