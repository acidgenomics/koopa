#!/usr/bin/env bash

koopa_activate_opt_prefix() { # {{{1
    # """
    # Activate koopa opt prefix.
    # @note Updated 2022-04-11.
    #
    # @examples
    # > koopa_activate_opt_prefix 'geos' 'proj' 'gdal'
    # """
    local dict name
    koopa_assert_has_args "$#"
    declare -A dict=(
        [cppflags]="${CPPFLAGS:-}"
        [ldflags]="${LDFLAGS:-}"
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    for name in "$@"
    do
        local prefix
        prefix="${dict[opt_prefix]}/${name}"
        koopa_assert_is_dir "$prefix"
        if koopa_is_empty_dir "$prefix"
        then
            koopa_stop "'${prefix}' is empty."
        fi
        koopa_alert "Activating '${prefix}'."
        # Set 'PATH' variable.
        koopa_activate_prefix "${prefix}"
        # Set 'CPPFLAGS' variable.
        koopa_add_to_cppflags_start "${prefix}/include"
        # Set 'LDFLAGS' variable.
        koopa_add_to_ldflags_start \
            "${prefix}/lib" \
            "${prefix}/lib64"
        # Set 'PKG_CONFIG_PATH' variable.
        koopa_add_to_pkg_config_path_start \
            "${prefix}/lib/pkgconfig" \
            "${prefix}/lib64/pkgconfig" \
            "${prefix}/share/pkgconfig"
    done
    return 0
}

koopa_add_to_cppflags_start() { # {{{1
    # """
    # Append a 'CPPFLAGS' string.
    # @note Updated 2022-04-11.
    # """
    local dir
    koopa_assert_has_args "$#"
    CPPFLAGS="${CPPFLAGS:-}"
    for dir in "$@"
    do
        local str
        [[ -d "$dir" ]] || continue
        str="-I${dir}"
        if [[ -n "$CPPFLAGS" ]]
        then
            CPPFLAGS="${str} ${CPPFLAGS}"
        else
            CPPFLAGS="$str"
        fi
    done
    export CPPFLAGS
    return 0
}

koopa_add_to_ldflags_start() { # {{{1
    # """
    # Append an 'LDFLAGS' string.
    # @note Updated 2022-04-12.
    #
    # Use '-rpath,${dir}' here not, '-rpath=${dir}'. This works on both
    # BSD/Unix (macOS) and Linux systems.
    # """
    local dict dir pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [allow_missing]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--allow-missing')
                dict[allow_missing]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for dir in "$@"
    do
        local str
        if [[ ! -d "$dir" ]]
        then
            [[ "${dict[allow_missing]}" -eq 0 ]] && continue
            str="-Wl,-rpath,${dir}"
        else
            str="-L${dir} -Wl,-rpath,${dir}"
        fi
        if [[ -n "$LDFLAGS" ]]
        then
            LDFLAGS="${str} ${LDFLAGS}"
        else
            LDFLAGS="$str"
        fi
    done
    export LDFLAGS
    return 0
}

koopa_add_to_pkg_config_path_start() { # {{{1
    # """
    # Force add to start of 'PKG_CONFIG_PATH'.
    # @note Updated 2022-04-11.
    # """
    local dir
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for dir in "$@"
    do
        [[ -d "$dir" ]] || continue
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$dir" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}

koopa_add_to_pkg_config_path_start_2() { # {{{1
    # """
    # Force add to start of 'PKG_CONFIG_PATH' using 'pc_path' variable
    # lookup from 'pkg-config' program.
    # @note Updated 2022-04-11.
    # """
    local app str
    koopa_assert_has_args "$#"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app in "$@"
    do
        [[ -x "$app" ]] || continue
        str="$("$app" --variable 'pc_path' 'pkg-config')"
        PKG_CONFIG_PATH="$( \
            __koopa_add_to_path_string_start "$PKG_CONFIG_PATH" "$str" \
        )"
    done
    export PKG_CONFIG_PATH
    return 0
}
