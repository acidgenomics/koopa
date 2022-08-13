#!/usr/bin/env bash

koopa_install_app_internal() {
    # """
    # Internal runner to install an application.
    # @note Updated 2022-08-12.
    # """
    local build_opt_arr opt_arr pos
    koopa_assert_has_args "$#"
    build_opt_arr=()
    opt_arr=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--activate-build-opt='*)
                build_opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-build-opt')
                build_opt_arr+=("${2:?}")
                shift 2
                ;;
            '--activate-opt='*)
                opt_arr+=("${1#*=}")
                shift 1
                ;;
            '--activate-opt')
                opt_arr+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '--link-in-bin='* | \
            '--link-in-bin' | \
            '--no-link-in-opt' | \
            '--no-prefix-check' | \
            '--quiet')
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if koopa_is_array_non_empty "${build_opt_arr[@]:-}"
    then
        koopa_activate_build_opt_prefix "${build_opt_arr[@]}"
    fi
    if koopa_is_array_non_empty "${opt_arr[@]:-}"
    then
        koopa_activate_opt_prefix "${opt_arr[@]}"
    fi
    koopa_install_app \
        --no-link-in-opt \
        --no-prefix-check \
        --no-restrict-path \
        --quiet \
        "$@"
}
