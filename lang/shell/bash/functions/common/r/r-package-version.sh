#!/usr/bin/env bash

koopa_r_package_version() {
    # """
    # R package version.
    # @note Updated 2022-07-11.
    #
    # @examples
    # > koopa_r_package_version 'basejump'
    # """
    local app str vec
    koopa_assert_has_args "$#"
    local -A app=(
        ['rscript']="$(koopa_locate_rscript)"
    )
    [[ -x "${app['rscript']}" ]] || exit 1
    pkgs=("$@")
    koopa_is_r_package_installed "${pkgs[@]}" || return 1
    vec="$(koopa_r_paste_to_vector "${pkgs[@]}")"
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
    koopa_print "$str"
    return 0
}
