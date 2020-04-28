#!/bin/sh
# shellcheck disable=SC2039

_koopa_r_home() {  # {{{1
    # """
    # R home prefix.
    #
    # @note Updated 2020-04-28.
    #
    # We're suppressing errors here that can pop up if 'etc' isn't linked yet
    # after a clean install. Can warn about ldpaths missing.
    # """
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local home
    home="$( \
        "$rscript_exe" \
            --vanilla \
            -e 'cat(Sys.getenv("R_HOME"))' \
        2>/dev/null \
    )"
    [ -d "$home" ] || return 1
    _koopa_print "$home"
    return 0
}

_koopa_r_library_prefix() {  # {{{1
    # """
    # R default library prefix.
    # @note Updated 2020-04-25.
    # """
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$("$rscript_exe" -e 'cat(.libPaths()[[1L]])')"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_package_version() {  # {{{1
    # """
    # R package version.
    # @note Updated 2020-04-25.
    # """
    local pkg
    pkg="${1:?}"
    local rscript_exe
    rscript_exe="${2:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    _koopa_is_r_package_installed "$pkg" "$rscript_exe" || return 1
    local x
    x="$("$rscript_exe" \
        -e "cat(as.character(packageVersion(\"${pkg}\")), \"\n\")" \
    )"
    _koopa_print "$x"
    return 0
}

_koopa_r_system_library_prefix() {  # {{{1
    # """
    # R system library prefix.
    # @note Updated 2020-04-25.
    # """
    local rscript_exe
    rscript_exe="${1:-Rscript}"
    _koopa_is_installed "$rscript_exe" || return 1
    local prefix
    prefix="$("$rscript_exe" --vanilla -e 'cat(tail(.libPaths(), n = 1L))')"
    [ -d "$prefix" ] || return 1
    _koopa_print "$prefix"
    return 0
}

_koopa_r_version() {  # {{{1
    # """
    # R version.
    # @note Updated 2020-04-25.
    # """
    local r_exe
    r_exe="${1:-R}"
    local x
    x="$("$r_exe" --version | head -n 1)"
    if _koopa_is_matching_fixed "$x" 'R Under development (unstable)'
    then
        x='devel'
    else
        x="$(_koopa_extract_version "$x")"
    fi
    _koopa_print "$x"
}
