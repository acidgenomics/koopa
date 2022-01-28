#!/usr/bin/env bash

koopa::julia_script_prefix() { # {{{1
    # """
    # Julia script prefix.
    # @note Updated 2021-06-14.
    # """
    koopa::print "$(koopa::koopa_prefix)/lang/julia/include"
    return 0
}

koopa::installers_prefix() { # {{{1
    # """
    # Koopa installers prefix.
    # @note Updated 2022-01-28.
    # """
    koopa::print "$(koopa::koopa_prefix)/lang/shell/bash/include/installers"
    return 0
}

# FIXME Rework using app/dict approach.
koopa::python_system_packages_prefix() { # {{{1
    # """
    # Python system site packages library prefix.
    # @note Updated 2021-10-29.
    # """
    local prefix python
    koopa::assert_has_args_le "$#" 1
    python="${1:-}"
    [[ -z "$python" ]] && python="$(koopa::locate_python)"
    koopa::is_installed "$python" || return 1
    prefix="$("$python" -c "import site; print(site.getsitepackages()[0])")"
    [[ -d "$prefix" ]] || return 1
    koopa::print "$prefix"
    return 0
}

# FIXME Rework using app/dict approach.
koopa::r_prefix() { # {{{1
    # """
    # R prefix.
    # @note Updated 2021-10-29.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    local prefix r rscript
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    rscript="${r}script"
    koopa::is_installed "$rscript" || return 1
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

# FIXME Rework using app/dict approach.
koopa::r_library_prefix() { # {{{1
    # """
    # R default library prefix.
    # @note Updated 2021-10-29.
    # """
    local prefix r rscript
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    rscript="${r}script"
    koopa::is_installed "$rscript" || return 1
    prefix="$("$rscript" -e 'cat(normalizePath(.libPaths()[[1L]]))')"
    [[ -d "$prefix" ]] || return 1
    koopa::print "$prefix"
    return 0
}

# FIXME Rework using app/dict approach.
koopa::r_system_library_prefix() { # {{{1
    # """
    # R system library prefix.
    # @note Updated 2021-10-29.
    # """
    local prefix r rscript
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    rscript="${r}script"
    koopa::is_installed "$rscript" || return 1
    prefix="$( \
        "$rscript" \
            --vanilla \
            -e 'cat(normalizePath(tail(.libPaths(), n = 1L)))' \
    )"
    [[ -d "$prefix" ]] || return 1
    koopa::print "$prefix"
    return 0
}
