#!/usr/bin/env bash

koopa_activate_build_opt_prefix() { # {{{1
    # """
    # Activate a build-only opt prefix.
    # @note Updated 2022-04-22.
    #
    # Useful for activation of 'cmake', 'make', 'pkg-config', etc.
    # """
    koopa_activate_opt_prefix --build-only "$@"
}

koopa_activate_opt_prefix() { # {{{1
    # """
    # Activate koopa opt prefix.
    # @note Updated 2022-04-22.
    #
    # Consider using pkg-config to manage CPPFLAGS and LDFLAGS:
    # > pkg-config --libs PKG_CONFIG_NAME...
    # > pkg-config --cflags PKG_CONFIG_NAME...
    #
    #
    # @examples
    # > koopa_activate_opt_prefix 'cmake' 'make'
    # """
    local app dict name pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [pkg_config]="$(koopa_locate_pkg_config --allow-missing)"
    )
    declare -A dict=(
        [build_only]=0
        [opt_prefix]="$(koopa_opt_prefix)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--build-only')
                dict[build_only]=1
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
    CPPFLAGS="${CPPFLAGS:-}"
    LDFLAGS="${LDFLAGS:-}"
    for name in "$@"
    do
        local pkgconfig_dirs prefix
        prefix="${dict[opt_prefix]}/${name}"
        koopa_assert_is_dir "$prefix"
        if koopa_is_empty_dir "$prefix"
        then
            koopa_stop "'${prefix}' is empty."
        fi
        prefix="$(koopa_realpath "$prefix")"
        if [[ "${dict[build_only]}" -eq 1 ]]
        then
            koopa_alert "Activating '${prefix}' (build only)."
        else
            koopa_alert "Activating '${prefix}'."
        fi
        # Set 'PATH' variable.
        koopa_activate_prefix "${prefix}"
        # Set 'PKG_CONFIG_PATH' variable.
        readarray -t pkgconfig_dirs <<< "$( \
            koopa_find \
                --pattern='pkgconfig' \
                --prefix="$prefix" \
                --sort \
                --type='d' \
            || true \
        )"
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            koopa_add_to_pkg_config_path "${pkgconfig_dirs[@]}"
        fi
        [[ "${dict[build_only]}" -eq 1 ]] && continue
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            local cflags libs pc_files
            # Loop across 'pkgconfig' dirs, find '*.pc' files, and ensure we
            # set 'cflags' and 'libs' automatically.
            readarray -t pc_files <<< "$( \
                koopa_find \
                    --prefix="$prefix" \
                    --type='f' \
                    --pattern='*.pc' \
                    --sort \
            )"
            # Set 'CPPFLAGS' variable.
            cflags="$("${app[pkg_config]}" --cflags "${pc_files[@]}")"
            if [[ -n "$cflags" ]]
            then
                CPPFLAGS="${CPPFLAGS:-} ${cflags}"
            fi
            # Set 'LDFLAGS' variable.
            libs="$("${app[pkg_config]}" --libs "${pc_files[@]}")"
            if [[ -n "$libs" ]]
            then
                LDFLAGS="${LDFLAGS:-} ${libs}"
            fi
        else
            # Set 'CPPFLAGS' variable.
            if [[ -d "${prefix}/include" ]]
            then
                CPPFLAGS="${CPPFLAGS:-} -I${prefix}/include"
            fi
            # Set 'LDFLAGS' variable.
            if [[ -d "${prefix}/lib" ]]
            then
                LDFLAGS="${LDFLAGS:-} -L${prefix}/lib"
            fi
            if [[ -d "${prefix}/lib64" ]]
            then
                LDFLAGS="${LDFLAGS:-} -L${prefix}/lib64"
            fi
        fi
    done
    [[ -n "$CPPFLAGS" ]] && export CPPFLAGS
    [[ -n "$LDFLAGS" ]] && export LDFLAGS
    return 0
}

koopa_add_rpath_to_ldflags() { # {{{1
    # """
    # Append 'LDFLAGS' string with an rpath.
    # @note Updated 2022-04-22.
    #
    # Use '-rpath,${dir}' here not, '-rpath=${dir}'. This approach works on
    # both BSD/Unix (macOS) and Linux systems.
    # """
    local dir
    koopa_assert_has_args "$#"
    LDFLAGS="${LDFLAGS:-}"
    for dir in "$@"
    do
        LDFLAGS="${LDFLAGS} -Wl,-rpath,${dir}"
    done
    export LDFLAGS
    return 0
}

koopa_add_to_pkg_config_path() { # {{{1
    # """
    # Force add to start of 'PKG_CONFIG_PATH'.
    # @note Updated 2022-04-21.
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

koopa_add_to_pkg_config_path_2() { # {{{1
    # """
    # Force add to start of 'PKG_CONFIG_PATH' using 'pc_path' variable
    # lookup from 'pkg-config' program.
    # @note Updated 2022-04-21.
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
