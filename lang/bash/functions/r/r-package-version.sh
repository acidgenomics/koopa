#!/usr/bin/env bash

_koopa_r_package_version() {
    # """
    # R package version.
    # @note Updated 2023-04-05.
    #
    # @examples
    # > _koopa_r_package_version 'koopa'
    # """
    local -A app
    local str vec
    _koopa_assert_has_args "$#"
    app['rscript']="$(_koopa_locate_rscript)"
    _koopa_assert_is_executable "${app[@]}"
    pkgs=("$@")
    _koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(_koopa_r_paste_to_vector "${pkgs[@]}")"
    str="$( \
        "${app['rscript']}" -e " \
            cat(vapply( \
                X = ${vec}, \
                FUN = function(x) { \
                    as.character(packageVersion(x)) \
                }, \
                FUN.VALUE = character(1L) \
            ), sep = '\n') \
        " \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}
