#!/usr/bin/env bash

koopa_activate_app() {
    # """
    # Activate koopa application for inclusion during compilation.
    # @note Updated 2023-08-18.
    #
    # Consider using 'pkg-config' to manage CFLAGS, CPPFLAGS, and LDFLAGS:
    # > pkg-config --libs PKG_CONFIG_NAME...
    # > pkg-config --cflags PKG_CONFIG_NAME...
    #
    # @section How to configure linker properly:
    #
    # - LDFLAGS: Extra flags to give to compilers when they are supposed to
    #   invoke the linker, 'ld', such as '-L'. Libraries ('-lfoo') should be
    #   added to the LDLIBS variable instead.
    # - LDLIBS: Library flags or names given to compilers when they are supposed
    #   to invoke the linker, 'ld'. Non-library linker flags, such as '-L',
    #   should go in the LDFLAGS variable.
    #
    # @section CFLAGS vs. CPPFLAGS vs. CXXFLAGS:
    #
    # CPPFLAGS is supposed to be for flags for the C PreProcessor; CXXFLAGS is
    # for flags for the C++ compiler. The default rules in make pass CPPFLAGS to
    # just about everything, CFLAGS is only passed when compiling and linking C,
    # and CXXFLAGS is only passed when compiling and linking C++.
    #
    # @seealso
    # - https://www.gnu.org/software/make/manual/
    # - https://www.gnu.org/software/make/manual/html_node/
    #     Implicit-Variables.html
    # - Variables: LD_RUN_PATH, LIBRARIES
    # - https://stackoverflow.com/questions/495598/
    # - https://stackoverflow.com/a/30482079/3911732/
    # - https://stackoverflow.com/a/55579265/3911732/
    # - https://stackoverflow.com/a/60142591/3911732/
    # - https://stackoverflow.com/questions/41836002/
    #
    # @examples
    # > koopa_activate_app 'cmake' 'make'
    # """
    local -A app dict
    local -a pos
    local app_name
    koopa_assert_has_args "$#"
    app['pkg_config']="$(koopa_locate_pkg_config --allow-missing)"
    dict['build_only']=0
    dict['opt_prefix']="$(koopa_opt_prefix)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--build-only')
                dict['build_only']=1
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
    CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}"
    CPPFLAGS="${CPPFLAGS:-}"
    LDFLAGS="${LDFLAGS:-}"
    LDLIBS="${LDLIBS:-}"
    # FIXME This may require system paths to be defined, and currently breaks
    # the gcc installer if it is defined.
    LIBRARY_PATH="${LIBRARY_PATH:-}"
    for app_name in "$@"
    do
        local -A dict2
        dict2['app_name']="$app_name"
        dict2['prefix']="${dict['opt_prefix']}/${dict2['app_name']}"
        koopa_assert_is_dir "${dict2['prefix']}"
        dict2['current_ver']="$(koopa_app_version "${dict2['app_name']}")"
        dict2['expected_ver']="$(koopa_app_json_version "${dict2['app_name']}")"
        # Shorten git commit string to 7 characters.
        if [[ "${#dict2['expected_ver']}" -eq 40 ]]
        then
            dict2['expected_ver']="${dict2['expected_ver']:0:7}"
        fi
        if [[ "${dict2['current_ver']}" != "${dict2['expected_ver']}" ]]
        then
            koopa_stop "'${dict2['app_name']}' version mismatch at \
'${dict2['prefix']}' (${dict2['current_ver']} != ${dict2['expected_ver']})."
        fi
        if koopa_is_empty_dir "${dict2['prefix']}"
        then
            koopa_stop "'${dict2['prefix']}' is empty."
        fi
        dict2['prefix']="$(koopa_realpath "${dict2['prefix']}")"
        if [[ "${dict['build_only']}" -eq 1 ]]
        then
            koopa_alert "Activating '${dict2['prefix']}' (build only)."
        else
            koopa_alert "Activating '${dict2['prefix']}'."
        fi
        # Set 'PATH' variable.
        koopa_add_to_path_start "${dict2['prefix']}/bin"
        # Set 'PKG_CONFIG_PATH' variable.
        readarray -t pkgconfig_dirs <<< "$( \
            koopa_find \
                --pattern='pkgconfig' \
                --prefix="${dict2['prefix']}" \
                --sort \
                --type='d' \
            || true \
        )"
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            koopa_add_to_pkg_config_path "${pkgconfig_dirs[@]}"
        fi
        [[ "${dict['build_only']}" -eq 1 ]] && continue
        if koopa_is_array_non_empty "${pkgconfig_dirs:-}"
        then
            if [[ ! -x "${app['pkg_config']}" ]]
            then
                koopa_stop "'pkg-config' is not installed."
            fi
            # Loop across 'pkgconfig' dirs, find '*.pc' files, and ensure we
            # configure 'make' implicit variables correctly.
            local -a pc_files
            readarray -t pc_files <<< "$( \
                koopa_find \
                    --prefix="${dict2['prefix']}" \
                    --type='f' \
                    --pattern='*.pc' \
                    --sort \
            )"
            dict2['cflags']="$( \
                "${app['pkg_config']}" --cflags "${pc_files[@]}" \
            )"
            dict2['ldflags']="$( \
                "${app['pkg_config']}" --libs-only-L "${pc_files[@]}" \
            )"
            dict2['ldlibs']="$( \
                "${app['pkg_config']}" --libs-only-l "${pc_files[@]}" \
            )"
            if [[ -n "${dict2['cflags']}" ]]
            then
                CPPFLAGS="${CPPFLAGS} ${dict2['cflags']}"
            fi
            if [[ -n "${dict2['ldflags']}" ]]
            then
                LDFLAGS="${LDFLAGS} ${dict2['ldflags']}"
            fi
            if [[ -n "${dict2['ldlibs']}" ]]
            then
                LDLIBS="${LDLIBS} ${dict2['ldlibs']}"
            fi
        else
            if [[ -d "${dict2['prefix']}/include" ]]
            then
                CPPFLAGS="${CPPFLAGS} -I${dict2['prefix']}/include"
            fi
            if [[ -d "${dict2['prefix']}/lib" ]]
            then
                LDFLAGS="${LDFLAGS} -L${dict2['prefix']}/lib"
            fi
            if [[ -d "${dict2['prefix']}/lib64" ]]
            then
                LDFLAGS="${LDFLAGS} -L${dict2['prefix']}/lib64"
            fi
        fi
        # Ensure we also configure 'LD_LIBRARY_PATH' and 'LIBRARY_PATH', which
        # is picked up by some apps that use make (e.g. sambamba).
        if [[ -d "${dict2['prefix']}/lib" ]]
        then
            LIBRARY_PATH="${LIBRARY_PATH}:${dict2['prefix']}/lib"
        fi
        if [[ -d "${dict2['prefix']}/lib64" ]]
        then
            LIBRARY_PATH="${LIBRARY_PATH}:${dict2['prefix']}/lib64"
        fi
        koopa_add_rpath_to_ldflags \
            "${dict2['prefix']}/lib" \
            "${dict2['prefix']}/lib64"
        # Ensure we configure CMake correctly for find_package.
        if [[ -d "${dict2['prefix']}/lib/cmake" ]]
        then
            CMAKE_PREFIX_PATH="${dict2['prefix']};${CMAKE_PREFIX_PATH}"
        fi
    done
    export CMAKE_PREFIX_PATH
    export CPPFLAGS
    export LDFLAGS
    export LDLIBS
    export LIBRARY_PATH
    return 0
}
