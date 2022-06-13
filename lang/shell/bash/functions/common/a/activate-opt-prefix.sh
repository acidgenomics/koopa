#!/usr/bin/env bash

koopa_activate_opt_prefix() {
    # """
    # Activate koopa opt prefix.
    # @note Updated 2022-06-01.
    #
    # Consider using pkg-config to manage CPPFLAGS and LDFLAGS:
    # > pkg-config --libs PKG_CONFIG_NAME...
    # > pkg-config --cflags PKG_CONFIG_NAME...
    #
    # @section How to configure linker properly:
    #
    # - LDFLAGS: Extra flags to give to compilers when they are supposed to
    #   invoke the linker, 'ld', such as '-L'. Libraries ('-lfoo') should be
    #   added to the LDLIBS variable instead.
    # - LDLIBS: Library flags or names given to compilers when they are supposed
    #   to invoke the linker, 'ld'. LOADLIBES is a deprecated (but still
    #   supported) alternative to LDLIBS. Non-library linker flags, such as
    #   '-L', should go in the LDFLAGS variable.
    #
    # @seealso
    # - https://www.gnu.org/software/make/manual/html_node/
    #     Implicit-Variables.html
    # - https://stackoverflow.com/a/30482079/3911732/
    # - https://stackoverflow.com/a/55579265/3911732/
    # - https://stackoverflow.com/a/60142591/3911732/
    # - https://stackoverflow.com/questions/41836002/
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
    LDLIBS="${LDLIBS:-}"
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
            local cflags ldflags ldlibs pc_files
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
            [[ -n "$cflags" ]] && CPPFLAGS="${CPPFLAGS:-} ${cflags}"
            # Set 'LDFLAGS' variable.
            ldflags="$("${app[pkg_config]}" --libs-only-L "${pc_files[@]}")"
            [[ -n "$ldflags" ]] && LDFLAGS="${LDFLAGS:-} ${ldflags}"
            # Set 'LDLIBS' variable. Can use '--libs-only-other' here.
            ldlibs="$("${app[pkg_config]}" --libs-only-l "${pc_files[@]}")"
            [[ -n "$ldlibs" ]] && LDLIBS="${LDLIBS:-} ${ldlibs}"
        else
            # Set 'CPPFLAGS' variable.
            [[ -d "${prefix}/include" ]] && \
                CPPFLAGS="${CPPFLAGS:-} -I${prefix}/include"
            # Set 'LDFLAGS' variable.
            [[ -d "${prefix}/lib" ]] && \
                LDFLAGS="${LDFLAGS:-} -L${prefix}/lib"
            [[ -d "${prefix}/lib64" ]] && \
                LDFLAGS="${LDFLAGS:-} -L${prefix}/lib64"
        fi
        koopa_add_rpath_to_ldflags \
            "${prefix}/lib" \
            "${prefix}/lib64"
    done
    export CPPFLAGS LDFLAGS LDLIBS
    return 0
}
