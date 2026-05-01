#!/usr/bin/env bash
# shellcheck disable=all


_koopa_activate_app() {
    # """
    # Activate koopa application for inclusion during compilation.
    # @note Updated 2025-08-21.
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
    # - https://gcc.gnu.org/onlinedocs/gcc/Environment-Variables.html
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
    # > _koopa_activate_app 'cmake' 'make'
    # """
    local -A app dict
    local -a pos
    local app_name
    _koopa_assert_has_args "$#"
    app['pkg_config']="$(_koopa_locate_pkg_config --allow-missing)"
    dict['build_only']=0
    dict['opt_prefix']="$(_koopa_opt_prefix)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Flags ------------------------------------------------------------
            '--build-only')
                dict['build_only']=1
                shift 1
                ;;
            # App version overrides --------------------------------------------
            'python')
                dict['python_version']="$(_koopa_python_major_minor_version)"
                pos+=("python${dict['python_version']}")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_has_args "$#"
    CMAKE_PREFIX_PATH="${CMAKE_PREFIX_PATH:-}"
    CPPFLAGS="${CPPFLAGS:-}"
    LDFLAGS="${LDFLAGS:-}"
    LDLIBS="${LDLIBS:-}"
    LIBRARY_PATH="${LIBRARY_PATH:-}"
    PATH="${PATH:-}"
    PKG_CONFIG_PATH="${PKG_CONFIG_PATH:-}"
    for app_name in "$@"
    do
        local -A dict2
        dict2['app_name']="$app_name"
        dict2['prefix']="${dict['opt_prefix']}/${dict2['app_name']}"
        _koopa_assert_is_dir "${dict2['prefix']}"
        dict2['current_ver']="$(_koopa_app_version "${dict2['app_name']}")"
        dict2['expected_ver']="$(_koopa_app_json_version "${dict2['app_name']}")"
        # Shorten git commit string to 7 characters.
        if [[ "${#dict2['expected_ver']}" -eq 40 ]]
        then
            dict2['expected_ver']="${dict2['expected_ver']:0:7}"
        fi
        if [[ "${dict2['current_ver']}" != "${dict2['expected_ver']}" ]]
        then
            _koopa_alert_note "'${dict2['app_name']}' version mismatch \
(${dict2['current_ver']} != ${dict2['expected_ver']}). \
Reinstalling to update."
            _koopa_install_app \
                "--name=${dict2['app_name']}" --reinstall || \
                _koopa_stop "Failed to reinstall '${dict2['app_name']}'."
            dict2['current_ver']="$( \
                _koopa_app_version "${dict2['app_name']}" \
            )"
            if [[ "${dict2['current_ver']}" != "${dict2['expected_ver']}" ]]
            then
                _koopa_stop "'${dict2['app_name']}' version mismatch \
persists after reinstall at '${dict2['prefix']}' \
(${dict2['current_ver']} != ${dict2['expected_ver']})."
            fi
        fi
        if _koopa_is_empty_dir "${dict2['prefix']}"
        then
            _koopa_stop "'${dict2['prefix']}' is empty."
        fi
        dict2['prefix']="$(_koopa_realpath "${dict2['prefix']}")"
        if [[ "${dict['build_only']}" -eq 1 ]]
        then
            _koopa_alert "Activating '${dict2['prefix']}' (build only)."
        else
            _koopa_alert "Activating '${dict2['prefix']}'."
        fi
        # Set 'PATH' variable.
        _koopa_add_to_path_start "${dict2['prefix']}/bin"
        # Set 'PKG_CONFIG_PATH' variable.
        readarray -t pkgconfig_dirs <<< "$( \
            _koopa_find \
                --pattern='pkgconfig' \
                --prefix="${dict2['prefix']}" \
                --sort \
                --type='d' \
            || true \
        )"
        if _koopa_is_array_non_empty "${pkgconfig_dirs[@]:-}"
        then
            _koopa_add_to_pkg_config_path "${pkgconfig_dirs[@]}"
        fi
        [[ "${dict['build_only']}" -eq 1 ]] && continue
        if _koopa_is_array_non_empty "${pkgconfig_dirs[@]:-}"
        then
            if [[ ! -x "${app['pkg_config']}" ]]
            then
                _koopa_stop "'pkg-config' is not installed."
            fi
            # Loop across 'pkgconfig' dirs, find '*.pc' files, and ensure we
            # configure 'make' implicit variables correctly.
            local -a pc_files
            readarray -t pc_files <<< "$( \
                _koopa_find \
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
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_start  \
                    "$LIBRARY_PATH" \
                    "${dict2['prefix']}/lib" \
            )"
        fi
        if [[ -d "${dict2['prefix']}/lib64" ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_start  \
                    "$LIBRARY_PATH" \
                    "${dict2['prefix']}/lib64" \
            )"
        fi
        _koopa_add_rpath_to_ldflags \
            "${dict2['prefix']}/lib" \
            "${dict2['prefix']}/lib64"
        # Ensure we configure CMake correctly for find_package.
        if [[ -d "${dict2['prefix']}/lib/cmake" ]]
        then
            CMAKE_PREFIX_PATH="${dict2['prefix']};${CMAKE_PREFIX_PATH}"
        fi
    done
    if [[ -n "$LIBRARY_PATH" ]]
    then
        if [[ -d '/usr/lib64' ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_end \
                    "$LIBRARY_PATH" \
                    '/usr/lib64' \
            )"
        fi
        if [[ -d '/usr/lib' ]]
        then
            LIBRARY_PATH="$( \
                _koopa_add_to_path_string_end \
                    "$LIBRARY_PATH" \
                    '/usr/lib' \
            )"
        fi
    fi
    # Decide whether to export global variables.
    if [[ -n "$CMAKE_PREFIX_PATH" ]]
    then
        CMAKE_PREFIX_PATH="$( \
            _koopa_str_unique_by_semicolon "$CMAKE_PREFIX_PATH" \
        )"
        export CMAKE_PREFIX_PATH
    else
        unset -v CMAKE_PREFIX_PATH
    fi
    if [[ -n "$CPPFLAGS" ]]
    then
        CPPFLAGS="$(_koopa_str_unique_by_space "$CPPFLAGS")"
        export CPPFLAGS
    else
        unset -v CPPFLAGS
    fi
    if [[ -n "$LDFLAGS" ]]
    then
        LDFLAGS="$(_koopa_str_unique_by_space "$LDFLAGS")"
        export LDFLAGS
    else
        unset -v LDFLAGS
    fi
    if [[ -n "$LDLIBS" ]]
    then
        LDLIBS="$(_koopa_str_unique_by_space "$LDLIBS")"
        export LDLIBS
    else
        unset -v LDLIBS
    fi
    if [[ -n "$LIBRARY_PATH" ]]
    then
        LIBRARY_PATH="$(_koopa_str_unique_by_colon "$LIBRARY_PATH")"
        export LIBRARY_PATH
    else
        unset -v LIBRARY_PATH
    fi
    if [[ -n "$PATH" ]]
    then
        PATH="$(_koopa_str_unique_by_colon "$PATH")"
        export PATH
    else
        unset -v PATH
    fi
    if [[ -n "$PKG_CONFIG_PATH" ]]
    then
        PKG_CONFIG_PATH="$(_koopa_str_unique_by_colon "$PKG_CONFIG_PATH")"
        export PKG_CONFIG_PATH
    else
        unset -v PKG_CONFIG_PATH
    fi
    return 0
}

# TODO Consider erroring if compiler is too old (e.g. GCC 4).
# We should run compiler checks before allowing the install to proceed.

# TODO Need to check that app is supported by parsing app.json file with
# Python, instead of just checking if function is defined in Bash library.
# We may be able to define this as '_koopa_is_app_supported'.
# With this approach, add support for platform-specific exclusion, such as
# 'ubuntu-22-amd64' for programs that fail to build only on a specific platform.
# TODO For builder machines that push app binaries, make sure we also build
# reverse dependencies after app update.
# TODO Our installer should drop an invisible build file into the directory
# that contains build number and date, for easy checking during updates.
# TODO Instead of erroring on an unsupported app, remove it when it exists
# and has been removed (e.g. 'llama', 'python3.10').
# TODO Alternatively, in the 'install --all' situation, just ignore existing
# directories from removed apps that are no longer supported.
_koopa_install_app() {
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2026-04-30.
    #
    # Refer to 'locale' for desired LC settings.
    #
    # @seealso
    # - https://stackoverflow.com/questions/692000/
    # """
    local -A app bool dict
    local -a bash_vars bin_arr env_vars man1_arr path_arr pos
    local i
    _koopa_assert_has_args "$#"
    _koopa_check_build_system
    # When enabled, this will change permissions on the top level directory
    # of the automatically generated prefix.
    bool['auto_prefix']=0
    # Download pre-built binary from our S3 bucket. Inspired by the
    # Homebrew bottle approach.
    bool['binary']=0
    _koopa_can_install_binary && bool['binary']=1
    # Install shared apps in bootstrap mode?
    bool['bootstrap']=0
    # Should we copy the log files into the install prefix?
    bool['copy_log_files']=0
    # Automatically install required dependencies (shared apps only).
    bool['deps']=1
    # Allow current environment variables to pass through for compiltion.
    bool['inherit_env']=0
    # When Lmod modules are active, ensure we inherit environment variables.
    _koopa_is_lmod_active && bool['inherit_env']=1
    # Perform the installation in an isolated subshell?
    bool['isolate']=1
    # Will any individual programs be linked into koopa 'bin/'?
    bool['link_in_bin']=0
    # Link corresponding man1 documentation files for app in bin.
    bool['link_in_man1']=0
    # Create an unversioned symlink in koopa 'opt/' directory.
    bool['link_in_opt']=0
    # This override is useful for app packages configuration.
    bool['prefix_check']=1
    # Whether current user has access to our private AWS S3 bucket.
    bool['private']=0
    # Push completed build to AWS S3 bucket (shared apps only).
    bool['push']=0
    _koopa_can_push_binary && bool['push']=1
    # This is useful for avoiding duplicate alert messages inside of
    # nested install calls (e.g. Emacs installer handoff to GNU app).
    bool['quiet']=0
    bool['reinstall']=0
    bool['update_ldconfig']=0
    bool['verbose']=0
    dict['app_prefix']="$(_koopa_app_prefix)"
    dict['cpu_count']="$(_koopa_cpu_count)"
    dict['installer']=''
    dict['mode']='shared'
    dict['name']=''
    dict['platform']='common'
    dict['prefix']=''
    dict['version']=''
    dict['version_key']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--installer='*)
                dict['installer']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            '--version-key='*)
                dict['version_key']="${1#*=}"
                shift 1
                ;;
            '--version-key')
                dict['version_key']="${2:?}"
                shift 2
                ;;
            # CLI user-accessible flags ----------------------------------------
            '--bootstrap')
                bool['bootstrap']=1
                shift 1
                ;;
            '--reinstall')
                bool['reinstall']=1
                shift 1
                ;;
            '--verbose')
                bool['verbose']=1
                shift 1
                ;;
            # Internal flags ---------------------------------------------------
            '--no-dependencies')
                bool['deps']=0
                shift 1
                ;;
            '--private')
                bool['private']=1
                shift 1
                ;;
            '--quiet')
                bool['quiet']=1
                shift 1
                ;;
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
                pos+=("${1:?}" "${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '')
                shift 1
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    [[ "${dict['mode']}" != 'shared' ]] && bool['deps']=0
    [[ -z "${dict['version_key']}" ]] && dict['version_key']="${dict['name']}"
    dict['current_version']="$(\
        _koopa_app_json_version "${dict['version_key']}" 2>/dev/null || true \
    )"
    [[ -z "${dict['version']}" ]] && \
        dict['version']="${dict['current_version']}"
    case "${dict['mode']}" in
        'shared')
            _koopa_assert_is_owner
            if [[ -z "${dict['prefix']}" ]]
            then
                bool['auto_prefix']=1
                dict['version2']="${dict['version']}"
                # Shorten git commit to 7 characters.
                [[ "${#dict['version']}" == 40 ]] && \
                    dict['version2']="${dict['version2']:0:7}"
                dict['prefix']="${dict['app_prefix']}/${dict['name']}/\
${dict['version2']}"
            fi
            if [[ "${dict['version']}" == "${dict['current_version']}" ]]
            then
                bool['link_in_bin']=1
                bool['link_in_man1']=1
                bool['link_in_opt']=1
            fi
            ;;
        'system')
            _koopa_assert_is_owner
            _koopa_assert_is_admin
            bool['isolate']=0
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            bool['prefix_check']=0
            bool['push']=0
            _koopa_is_linux && bool['update_ldconfig']=1
            ;;
        'user')
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            bool['push']=0
            ;;
    esac
    if [[ "${bool['binary']}" -eq 1 ]] || \
        [[ "${bool['private']}" -eq 1 ]] || \
        [[ "${bool['push']}" -eq 1 ]]
    then
        _koopa_assert_has_private_access
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ "${bool['prefix_check']}" -eq 1 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            if [[ ! -f "${dict['prefix']}/.install/stdout.log" ]] \
                && [[ ! -f "${dict['prefix']}/.koopa-install-stdout.log" ]]
            then
                bool['reinstall']=1
            fi
            if [[ "${bool['reinstall']}" -eq 1 ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    _koopa_alert_uninstall_start \
                        "${dict['name']}" "${dict['prefix']}"
                case "${dict['mode']}" in
                    'system')
                        _koopa_rm --sudo "${dict['prefix']}"
                        ;;
                    *)
                        _koopa_rm "${dict['prefix']}"
                        ;;
                esac
            fi
            [[ -d "${dict['prefix']}" ]] && return 0
        fi
    fi
    if [[ "${bool['deps']}" -eq 1 ]]
    then
        local dep deps deps_str
        deps_str="$(_koopa_app_dependencies "${dict['name']}")" || \
            _koopa_stop "Failed to resolve dependencies for '${dict['name']}'."
        readarray -t deps <<< "$deps_str"
        if _koopa_is_array_non_empty "${deps[@]:-}"
        then
            _koopa_dl \
                "${dict['name']} dependencies" \
                "$(_koopa_to_string "${deps[@]}")"
            for dep in "${deps[@]}"
            do
                local -a dep_install_args
                if [[ "$dep" == "${dict['name']}" ]]
                then
                    continue
                fi
                if [[ -d "$(_koopa_app_prefix --allow-missing "$dep")" ]]
                then
                    continue
                fi
                dep_install_args=("--name=${dep}")
                if [[ "${bool['bootstrap']}" -eq 1 ]]
                then
                    dep_install_args+=('--bootstrap')
                fi
                if [[ "${bool['verbose']}" -eq 1 ]]
                then
                    dep_install_args+=('--verbose')
                fi
                _koopa_install_app "${dep_install_args[@]}"
            done
        fi
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        _koopa_alert_install_start "${dict['name']}" "${dict['prefix']}"
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ ! -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                dict['prefix']="$(_koopa_init_dir --sudo "${dict['prefix']}")"
                ;;
            *)
                dict['prefix']="$(_koopa_init_dir "${dict['prefix']}")"
                ;;
        esac
    fi
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        [[ "${dict['mode']}" == 'shared' ]] || return 1
        [[ -n "${dict['prefix']}" ]] || return 1
        _koopa_install_app_from_binary_package "${dict['prefix']}"
    elif [[ "${bool['isolate']}" -eq 0 ]]
    then
        export KOOPA_INSTALL_APP_SUBSHELL=1
        _koopa_install_app_subshell \
            --installer="${dict['installer']}" \
            --mode="${dict['mode']}" \
            --name="${dict['name']}" \
            --platform="${dict['platform']}" \
            --prefix="${dict['prefix']}" \
            --version="${dict['version']}" \
            "$@"
        unset -v KOOPA_INSTALL_APP_SUBSHELL
    else
        if [[ "${bool['bootstrap']}" -eq 1 ]]
        then
            app['bash']="${KOOPA_BOOTSTRAP_PREFIX:?}/bin/bash"
            # > path_arr+=("${KOOPA_BOOTSTRAP_PREFIX:?}/bin")
        else
            app['bash']="$(_koopa_locate_bash --allow-missing)"
            if [[ ! -x "${app['bash']}" ]]
            then
                if _koopa_is_macos
                then
                    app['bash']="$(_koopa_locate_bash --allow-bootstrap)"
                else
                    app['bash']="$(_koopa_locate_bash --allow-system)"
                fi
            fi
        fi
        app['env']="$(_koopa_locate_env --allow-system)"
        app['tee']="$(_koopa_locate_tee --allow-system)"
        _koopa_assert_is_executable "${app[@]}"
        if [[ "${bool['inherit_env']}" -eq 1 ]]
        then
            dict['path']="${PATH:?}"
            env_vars+=(
                "CC=${CC:-}"
                "CPATH=${CPATH:-}"
                "CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH:-}"
                "CXX=${CXX:-}"
                "C_INCLUDE_PATH=${C_INCLUDE_PATH:-}"
                "F77=${F77:-}"
                "FC=${FC:-}"
                "INCLUDE=${INCLUDE:-}"
                "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
                "LIBRARY_PATH=${LIBRARY_PATH:-}"
                "PKG_CONFIG_PATH=${PKG_CONFIG_PATH:-}"
            )
        else
            path_arr+=('/usr/bin' '/usr/sbin' '/bin' '/sbin')
            dict['path']="$(_koopa_paste --sep=':' "${path_arr[@]}")"
        fi
        env_vars+=(
            "HOME=${HOME:?}"
            'KOOPA_ACTIVATE=0'
            "KOOPA_CPU_COUNT=${dict['cpu_count']}"
            'KOOPA_INSTALL_APP_SUBSHELL=1'
            "KOOPA_VERBOSE=${bool['verbose']}"
            'LANG=C'
            'LC_ALL=C'
            "PATH=${dict['path']}"
            "PWD=${HOME:?}"
            "TMPDIR=${TMPDIR:-/tmp}"
        )
        [[ -n "${KOOPA_CAN_INSTALL_BINARY:-}" ]] && \
            env_vars+=("KOOPA_CAN_INSTALL_BINARY=${KOOPA_CAN_INSTALL_BINARY:?}")
        # TLS/SSL CA certificates ----------------------------------------------
        [[ -n "${AWS_CA_BUNDLE:-}" ]] && \
            env_vars+=("AWS_CA_BUNDLE=${AWS_CA_BUNDLE:-}")
        [[ -n "${DEFAULT_CA_BUNDLE_PATH:-}" ]] && \
            env_vars+=("DEFAULT_CA_BUNDLE_PATH=${DEFAULT_CA_BUNDLE_PATH:-}")
        [[ -n "${NODE_EXTRA_CA_CERTS:-}" ]] && \
            env_vars+=("NODE_EXTRA_CA_CERTS=${NODE_EXTRA_CA_CERTS:-}")
        [[ -n "${REQUESTS_CA_BUNDLE:-}" ]] && \
            env_vars+=("REQUESTS_CA_BUNDLE=${REQUESTS_CA_BUNDLE:-}")
        [[ -n "${SSL_CERT_FILE:-}" ]] && \
            env_vars+=("SSL_CERT_FILE=${SSL_CERT_FILE:-}")
        # HTTP proxy server ----------------------------------------------------
        [[ -n "${HTTP_PROXY:-}" ]] && \
            env_vars+=("HTTP_PROXY=${HTTP_PROXY:?}")
        [[ -n "${HTTPS_PROXY:-}" ]] && \
            env_vars+=("HTTPS_PROXY=${HTTPS_PROXY:?}")
        [[ -n "${http_proxy:-}" ]] && \
            env_vars+=("http_proxy=${http_proxy:?}")
        [[ -n "${https_proxy:-}" ]] && \
            env_vars+=("https_proxy=${https_proxy:?}")
        # Application-specific variables ---------------------------------------
        [[ -n "${GOPROXY:-}" ]] && \
            env_vars+=("GOPROXY=${GOPROXY:-}")
        [[ -n "${PYTHON_BUILD_MIRROR_URL:-}" ]] && \
            env_vars+=("PYTHON_BUILD_MIRROR_URL=${PYTHON_BUILD_MIRROR_URL:-}")
        if [[ "${dict['mode']}" == 'shared' ]] \
            && [[ "${bool['inherit_env']}" -eq 0 ]]
        then
            PKG_CONFIG_PATH=''
            app['pkg_config']="$( \
                _koopa_locate_pkg_config --allow-missing --only-system \
            )"
            if [[ -x "${app['pkg_config']}" ]]
            then
                _koopa_activate_pkg_config "${app['pkg_config']}"
            fi
            env_vars+=("PKG_CONFIG_PATH=${PKG_CONFIG_PATH}")
            unset -v PKG_CONFIG_PATH
        fi
        if [[ "${dict['mode']}" == 'shared' ]] \
            && [[ -d "${dict['prefix']}" ]]
        then
            bool['copy_log_files']=1
        fi
        dict['header_file']="$(_koopa_bash_prefix)/include/header.sh"
        dict['stderr_file']="$(_koopa_tmp_log_file)"
        dict['stdout_file']="$(_koopa_tmp_log_file)"
        _koopa_assert_is_file \
            "${dict['header_file']}" \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
        # shellcheck disable=SC2064
        trap "_koopa_rm \
            '${dict['stderr_file']}' \
            '${dict['stdout_file']}'" \
            EXIT
        bash_vars=(
            '--noprofile'
            '--norc'
            '-o' 'errexit'
            '-o' 'errtrace'
            '-o' 'nounset'
            '-o' 'pipefail'
        )
        if [[ "${bool['verbose']}" -eq 1 ]]
        then
            bash_vars+=('-o' 'verbose')
        fi
        local -a subshell_args
        subshell_args=(
            "--installer='${dict['installer']}'"
            "--mode='${dict['mode']}'"
            "--name='${dict['name']}'"
            "--platform='${dict['platform']}'"
            "--prefix='${dict['prefix']}'"
            "--version='${dict['version']}'"
        )
        local arg
        for arg in "$@"
        do
            subshell_args+=("'${arg}'")
        done
        "${app['env']}" -i \
            "${env_vars[@]}" \
            "${app['bash']}" \
                "${bash_vars[@]}" \
                -c "source '${dict['header_file']}'; \
                    _koopa_install_app_subshell \
                        ${subshell_args[*]}" \
            > >("${app['tee']}" "${dict['stdout_file']}") \
            2> >("${app['tee']}" "${dict['stderr_file']}" >&2)
        if [[ "${bool['copy_log_files']}" -eq 1 ]] && \
            [[ -d "${dict['prefix']}" ]]
        then
            local install_dir
            install_dir="${dict['prefix']}/.install"
            _koopa_mkdir "$install_dir"
            _koopa_cp \
                "${dict['stdout_file']}" \
                "${install_dir}/stdout.log"
            _koopa_cp \
                "${dict['stderr_file']}" \
                "${install_dir}/stderr.log"
            "${KOOPA_PREFIX:?}/bin/koopa" internal write-install-info \
                "${install_dir}/info.json" \
                "${dict['name']}" \
                "${dict['version']}"
        fi
        _koopa_rm \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
        trap - EXIT
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['link_in_opt']}" -eq 1 ]]
            then
                _koopa_link_in_opt \
                    --name="${dict['name']}" \
                    --source="${dict['prefix']}"
            fi
            if [[ "${bool['link_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    _koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if _koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    for i in "${!bin_arr[@]}"
                    do
                        local -A dict2
                        dict2['name']="${bin_arr[$i]}"
                        dict2['source']="${dict['prefix']}/bin/${dict2['name']}"
                        _koopa_link_in_bin \
                            --name="${dict2['name']}" \
                            --source="${dict2['source']}"
                    done
                fi
            fi
            if [[ "${bool['link_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    _koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if _koopa_is_array_non_empty "${man1_arr[@]:-}"
                then
                    for i in "${!man1_arr[@]}"
                    do
                        local -A dict2
                        dict2['name']="${man1_arr[$i]}"
                        dict2['mf1']="${dict['prefix']}/share/man/\
man1/${dict2['name']}"
                        dict2['mf2']="${dict['prefix']}/man/\
man1/${dict2['name']}"
                        if [[ -f "${dict2['mf1']}" ]]
                        then
                            _koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf1']}"
                        elif [[ -f "${dict2['mf2']}" ]]
                        then
                            _koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf2']}"
                        fi
                    done
                fi
            fi
            if [[ "${bool['push']}" -eq 1 ]]
            then
                _koopa_push_app_build "${dict['name']}"
            fi
            ;;
        'system')
            if [[ "${bool['update_ldconfig']}" -eq 1 ]]
            then
                _koopa_linux_update_ldconfig
            fi
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        _koopa_alert_install_success "${dict['name']}" "${dict['prefix']}"
    fi
    return 0
}

_koopa_install_app_subshell() {
    # """
    # Install an application in a hardened subshell.
    # @note Updated 2023-08-29.
    # """
    local -A dict
    local -a pos
    _koopa_assert_is_install_subshell
    dict['installer_bn']=''
    dict['installer_fun']='main'
    dict['mode']='shared'
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['platform']='common'
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--installer='*)
                dict['installer_bn']="${1#*=}"
                shift 1
                ;;
            '--installer')
                dict['installer_bn']="${2:?}"
                shift 2
                ;;
            '--mode='*)
                dict['mode']="${1#*=}"
                shift 1
                ;;
            '--mode')
                dict['mode']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--platform='*)
                dict['platform']="${1#*=}"
                shift 1
                ;;
            '--platform')
                dict['platform']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Internal flags ---------------------------------------------------
            '--system')
                dict['mode']='system'
                shift 1
                ;;
            '--user')
                dict['mode']='user'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
                pos+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${dict['installer_bn']}" ]] && dict['installer_bn']="${dict['name']}"
    dict['installer_file']="$(_koopa_bash_prefix)/include/install/\
${dict['platform']}/${dict['mode']}/${dict['installer_bn']}.sh"
    _koopa_assert_is_file "${dict['installer_file']}"
    (
        _koopa_cd "${dict['tmp_dir']}"
        # shellcheck disable=SC2030
        export KOOPA_INSTALL_NAME="${dict['name']}"
        # shellcheck disable=SC2030
        export KOOPA_INSTALL_PREFIX="${dict['prefix']}"
        # shellcheck disable=SC2030
        export KOOPA_INSTALL_VERSION="${dict['version']}"
        # shellcheck source=/dev/null
        source "${dict['installer_file']}"
        _koopa_assert_is_function "${dict['installer_fun']}"
        "${dict['installer_fun']}" "$@"
        return 0
    )
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_install_app_from_binary_package() {
    # """
    # Install app from pre-built binary package.
    # @note Updated 2024-06-21.
    #
    # @examples
    # > _koopa_install_app_from_binary_package \
    # >     '/opt/koopa/app/aws-cli/2.7.7' \
    # >     '/opt/koopa/app/bash/5.1.16'
    # """
    local -A app dict
    local prefix
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws --allow-system)"
    app['tar']="$(_koopa_locate_tar --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch2)" # e.g. 'amd64'.
    dict['aws_profile']='acidgenomics'
    dict['binary_prefix']='/opt/koopa'
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['os_string']="$(_koopa_os_string)"
    dict['s3_bucket']="s3://private.koopa.acidgenomics.com/binaries"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        _koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -A dict2
        dict2['prefix']="$(_koopa_realpath "$prefix")"
        dict2['name']="$( \
            _koopa_print "${dict2['prefix']}" \
                | _koopa_dirname \
                | _koopa_basename \
        )"
        dict2['version']="$(_koopa_basename "$prefix")"
        dict2['tar_file']="${dict['tmp_dir']}/${dict2['name']}-\
${dict2['version']}.tar.gz"
        dict2['tar_url']="${dict['s3_bucket']}/${dict['os_string']}/\
${dict['arch']}/${dict2['name']}/${dict2['version']}.tar.gz"
        # Can quiet down with '--only-show-errors' here.
        "${app['aws']}" s3 cp \
            --profile "${dict['aws_profile']}" \
            "${dict2['tar_url']}" \
            "${dict2['tar_file']}"
        _koopa_assert_is_file "${dict2['tar_file']}"
        # Can increase verbosity with '-v' here.
        "${app['tar']}" -Pxz -f "${dict2['tar_file']}"
        _koopa_touch "${prefix}/.koopa-binary"
    done
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}

_koopa_install_gnu_app() {
    # """
    # Build and install a GNU package from source.
    # @note Updated 2024-12-03.
    #
    # Positional arguments are passed to 'conf_args' array.
    # """
    local -A dict
    local -a conf_args
    _koopa_assert_is_install_subshell
    dict['compress_ext']='gz'
    dict['jobs']="$(_koopa_cpu_count)"
    dict['mirror']="$(_koopa_gnu_mirror_url)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['parent_name']=''
    dict['pkg_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    conf_args=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--compress-ext='*)
                dict['compress_ext']="${1#*=}"
                shift 1
                ;;
            '--compress-ext')
                dict['compress_ext']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--mirror='*)
                dict['mirror']="${1#*=}"
                shift 1
                ;;
            '--mirror')
                dict['mirror']="${2:?}"
                shift 2
                ;;
            '--package-name='*)
                dict['pkg_name']="${1#*=}"
                shift 1
                ;;
            '--package-name')
                dict['pkg_name']="${2:?}"
                shift 2
                ;;
            '--parent-name='*)
                dict['parent_name']="${1#*=}"
                shift 1
                ;;
            '--parent-name')
                dict['parent_name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--non-gnu-mirror')
                # Alternative URLs:
                # - https://download.savannah.gnu.org/releases
                # - https://download.savannah.nongnu.org/releases
                # - https://mirrors.sarata.com/non-gnu
                dict['mirror']='https://download.savannah.nongnu.org/releases'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            # Inspired by CMake approach using '-D' prefix.
            '-D')
                conf_args+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${dict['parent_name']}" ]] && dict['parent_name']="${dict['name']}"
    [[ -z "${dict['pkg_name']}" ]] && dict['pkg_name']="${dict['name']}"
    _koopa_assert_is_set \
        '--mirror' "${dict['mirror']}" \
        '--name' "${dict['name']}" \
        '--package-name' "${dict['pkg_name']}" \
        '--parent-name' "${dict['parent_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    conf_args+=("--prefix=${dict['prefix']}")
    export FORCE_UNSAFE_CONFIGURE=1
    dict['url']="${dict['mirror']}/${dict['parent_name']}/\
${dict['pkg_name']}-${dict['version']}.tar.${dict['compress_ext']}"
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_make_build "${conf_args[@]}"
    return 0
}

_koopa_install_go_package() {
    # """
    # Install a Go package using 'go install'.
    # @note Updated 2023-12-22.
    #
    # @seealso
    # - go help install
    # """
    local -A app dict
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'go'
    app['go']="$(_koopa_locate_go)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['url']=''
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}"
    export GOBIN="${dict['prefix']}/bin"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    _koopa_print_env
    "${app['go']}" install "${dict['url']}"
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}

_koopa_install_conda_package() {
    # """
    # Install a conda environment as an application.
    # @note Updated 2026-01-05.
    #
    # Be sure to excluded nested directories that may exist in 'libexec' 'bin',
    # such as 'bin/scripts' for bowtie2.
    #
    # Consider adding 'man1' support for relevant apps (e.g. 'hisat2').
    #
    # @seealso
    # - https://github.com/conda/conda/issues/7741
    # """
    local -A app dict
    local -a bin_names create_args pos
    local bin_name
    _koopa_assert_is_install_subshell
    app['conda']="$(_koopa_locate_conda)"
    _koopa_assert_is_executable "${app[@]}"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['channels']=''
    dict['yaml_file']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--file='*)
                dict['yaml_file']="${1#*=}"
                shift 1
                ;;
            '--file')
                dict['yaml_file']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                _koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['name']}" \
        '--version' "${dict['name']}"
    create_args=()
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    create_args+=("--prefix=${dict['libexec']}")
    if [[ -n "${dict['yaml_file']}" ]]
    then
        _koopa_assert_is_file "${dict['yaml_file']}"
        create_args+=("--file=${dict['yaml_file']}")
    else
        dict['channels']="$("${app['conda']}" config --show channels)"
        if ! _koopa_str_detect_fixed \
                --pattern='conda-forge' \
                --string="${dict['channels']}"
        then
            create_args+=(
                '--channel=conda-forge'
                '--channel=bioconda'
            )
        fi
        create_args+=("${dict['name']}==${dict['version']}")
    fi
    _koopa_dl 'conda create env args' "${create_args[*]}"
    if _koopa_is_verbose
    then
        "${app['conda']}" config --json --show
        "${app['conda']}" config --json --show-sources
    fi
    _koopa_conda_create_env "${create_args[@]}"
    dict['json_pattern']="${dict['name']}-${dict['version']}-*.json"
    case "${dict['name']}" in
        'snakemake')
            dict['json_pattern']="${dict['name']}-minimal-*.json"
            ;;
    esac
    dict['json_file']="$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --pattern="${dict['json_pattern']}" \
            --prefix="${dict['libexec']}/conda-meta" \
            --type='f' \
    )"
    _koopa_assert_is_file "${dict['json_file']}"
    readarray -t bin_names <<< "$( \
        _koopa_conda_bin_names "${dict['json_file']}" \
    )"
    if _koopa_is_array_non_empty "${bin_names[@]:-}"
    then
        for bin_name in "${bin_names[@]}"
        do
            local -A dict2
            dict2['name']="$bin_name"
            dict2['bin_source']="${dict['libexec']}/bin/${dict2['name']}"
            dict2['bin_target']="${dict['prefix']}/bin/${dict2['name']}"
            dict2['man1_source']="${dict['libexec']}/share/man/\
man1/${dict2['name']}.1"
            dict2['man1_target']="${dict['prefix']}/share/man/\
man1/${dict2['name']}.1"
            _koopa_assert_is_file "${dict2['bin_source']}"
            _koopa_ln "${dict2['bin_source']}" "${dict2['bin_target']}"
            if [[ -f "${dict2['man1_source']}" ]]
            then
                _koopa_ln "${dict2['man1_source']}" "${dict2['man1_target']}"
            fi
        done
    fi
    return 0
}

_koopa_install_rust_package() {
    # """
    # Install Rust package.
    # @note Updated 2024-10-23.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # @seealso
    # Setting custom linker arguments using RUSTFLAGS:
    # - https://doc.rust-lang.org/cargo/reference/environment-variables.html#
    #     environment-variables-cargo-reads
    # - https://internals.rust-lang.org/t/compiling-rustc-with-non-standard-
    #     flags/8950/6
    # - https://github.com/rust-lang/cargo/issues/5077
    # - https://news.ycombinator.com/item?id=29570931
    # """
    local -A app bool dict
    local -a build_deps install_args pos
    _koopa_assert_is_install_subshell
    build_deps+=(
        # > 'git'
        'rust'
    )
    _koopa_activate_app --build-only "${build_deps[@]}"
    app['cargo']="$(_koopa_locate_cargo)"
    _koopa_assert_is_executable "${app[@]}"
    bool['openssl']=0
    dict['cargo_config_file']="$(_koopa_rust_cargo_config_file)"
    dict['cargo_home']="$(_koopa_init_dir 'cargo')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Passthrough key value pairs --------------------------------------
            '--features='* | \
            '--git='* | \
            '--tag='*)
                # e.g. '--features=extra'.
                # left-hand side: "${1%%=*}" (e.g. '--features').
                # right-hand side: "${1#*=}" (e.g. 'extra').
                pos+=("${1%%=*}" "${1#*=}")
                shift 1
                ;;
            '--features' | \
            '--git' | \
            '--tag')
                pos+=("$1" "$2")
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--with-openssl')
                bool['openssl']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_dir "${dict['cargo_home']}"
    export CARGO_HOME="${dict['cargo_home']}"
    export CARGO_NET_GIT_FETCH_WITH_CLI='true'
    export RUST_BACKTRACE='full'
    if [[ "${bool['openssl']}" -eq 1 ]]
    then
        _koopa_activate_app 'openssl'
        dict['openssl']="$(_koopa_app_prefix 'openssl')"
        export OPENSSL_DIR="${dict['openssl']}"
    fi
    if [[ -n "${LDFLAGS:-}" ]]
    then
        local -a ldflags rustflags
        local ldflag
        rustflags=()
        IFS=' ' read -r -a ldflags <<< "${LDFLAGS:?}"
        for ldflag in "${ldflags[@]}"
        do
            rustflags+=('-C' "link-arg=${ldflag}")
        done
        export RUSTFLAGS="${rustflags[*]}"
    fi
    if [[ -f "${dict['cargo_config_file']}" ]]
    then
        _koopa_alert "Using cargo config at '${dict['cargo_config_file']}'."
        _koopa_cp --verbose \
            "${dict['cargo_config_file']}" \
            "${CARGO_HOME:?}/config.toml"
    else
        install_args+=(
            '--config' 'net.git-fetch-with-cli=true'
            '--config' 'net.retry=5'
        )
    fi
    install_args+=(
        '--jobs' "${dict['jobs']}"
        '--locked'
        '--root' "${dict['prefix']}"
        '--verbose'
        '--version' "${dict['version']}"
    )
    [[ "$#" -gt 0 ]] && install_args+=("$@")
    install_args+=("${dict['name']}")
    # Ensure we put Rust package 'bin/' into PATH, to avoid installer warning.
    dict['bin_prefix']="$(_koopa_init_dir "${dict['prefix']}/bin")"
    _koopa_add_to_path_start "${dict['bin_prefix']}"
    _koopa_print_env
    _koopa_dl 'cargo install args' "${install_args[*]}"
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}

_koopa_install_node_package() {
    # """
    # Install Node.js package using npm.
    # @note Updated 2026-04-24.
    #
    # @seealso
    # - npm help config
    # - npm help install
    # - npm config get prefix
    # - https://github.com/Homebrew/brew/blob/master/Library/Homebrew/
    #     language/node.rb
    # """
    local -A app dict
    local -a extra_pkgs install_args
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'node'
    app['node']="$(_koopa_locate_node --realpath)"
    app['npm']="$(_koopa_locate_npm)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cache_prefix']="$(_koopa_tmp_dir)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    export NPM_CONFIG_PREFIX="${dict['prefix']}"
    export NPM_CONFIG_UPDATE_NOTIFIER=false
    _koopa_is_root && install_args+=('--unsafe-perm')
    install_args+=(
        "--cache=${dict['cache_prefix']}"
        '--global'
        '--loglevel=silly' # -ddd
        '--no-audit'
        '--no-fund'
        "${dict['name']}@${dict['version']}"
    )
    if _koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    _koopa_dl 'npm install args' "${install_args[*]}"
    "${app['npm']}" install "${install_args[@]}" 2>&1
    _koopa_rm "${dict['cache_prefix']}"
    return 0
}

_koopa_install_python_package() {
    # """
    # Install a Python package as a virtual environment application.
    # @note Updated 2025-08-21.
    #
    # @seealso
    # - https://adamj.eu/tech/2019/03/11/pip-install-from-a-git-repository/
    # """
    local -A app bool dict
    local -a bin_names extra_pkgs man1_names venv_args
    local bin_name man1_name
    _koopa_assert_is_install_subshell
    app['cut']="$(_koopa_locate_cut --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    bool['binary']=1
    bool['egg_name']=0
    dict['egg_name']=''
    dict['locate_python']='_koopa_locate_python'
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['pip_name']=''
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['py_maj_ver']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--egg-name='*)
                dict['egg_name']="${1#*=}"
                shift 1
                ;;
            '--egg-name')
                dict['egg_name']="${2:?}"
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--pip-name='*)
                dict['pip_name']="${1#*=}"
                shift 1
                ;;
            '--pip-name')
                dict['pip_name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--python-version='*)
                dict['py_maj_ver']="${1#*=}"
                shift 1
                ;;
            '--python-version')
                dict['py_maj_ver']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--no-binary')
                bool['binary']=0
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    if [[ -n "${dict['egg_name']}" ]]
    then
        bool['egg_name']=1
    else
        dict['egg_name']="${dict['name']}"
    fi
    if [[ -z "${dict['pip_name']}" ]]
    then
        dict['pip_name']="${dict['egg_name']}"
    fi
    if [[ "${bool['egg_name']}" -eq 0 ]]
    then
        dict['egg_name']="$(_koopa_snake_case "${dict['egg_name']}")"
    fi
    _koopa_assert_is_set \
        '--egg-name' "${dict['egg_name']}" \
        '--name' "${dict['name']}" \
        '--pip-name' "${dict['pip_name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    if [[ -n "${dict['py_maj_ver']}" ]]
    then
        # e.g. '3.11' to '311'.
        dict['py_maj_ver_2']="$( \
            _koopa_gsub \
                --fixed \
                --pattern='.'  \
                --replacement='' \
                "${dict['py_maj_ver']}" \
        )"
        dict['locate_python']="_koopa_locate_python${dict['py_maj_ver_2']}"
    fi
    _koopa_assert_is_function "${dict['locate_python']}"
    app['python']="$("${dict['locate_python']}" --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_add_to_path_start "$(_koopa_parent_dir "${app['python']}")"
    dict['libexec']="${dict['prefix']}/libexec"
    dict['py_version']="$(_koopa_get_version "${app['python']}")"
    dict['py_maj_min_ver']="$( \
        _koopa_major_minor_version "${dict['py_version']}" \
    )"
    venv_args=(
        "--prefix=${dict['libexec']}"
        "--python=${app['python']}"
    )
    if [[ "${bool['binary']}" -eq 0 ]]
    then
        venv_args+=('--no-binary')
    fi
    venv_args+=("${dict['pip_name']}==${dict['version']}")
    if _koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        venv_args+=("${extra_pkgs[@]}")
    fi
    _koopa_print_env
    _koopa_python_create_venv "${venv_args[@]}"
    dict['record_file']="${dict['libexec']}/lib/\
python${dict['py_maj_min_ver']}/site-packages/\
${dict['egg_name']}-${dict['version']}.dist-info/RECORD"
    _koopa_assert_is_file "${dict['record_file']}"
    # Ensure we exclude any nested subdirectories in libexec bin, which is
    # known to happen with some conda recipes (e.g. bowtie2).
    readarray -t bin_names <<< "$( \
        _koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./bin/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '5' \
    )"
    readarray -t man1_names <<< "$( \
        _koopa_grep \
            --file="${dict['record_file']}" \
            --pattern='^\.\./\.\./\.\./share/man/man1/[^/]+,' \
            --regex \
        | "${app['cut']}" -d ',' -f '1' \
        | "${app['cut']}" -d '/' -f '7' \
    )"
    if _koopa_is_array_empty "${bin_names[@]:-}"
    then
        _koopa_stop "Failed to parse '${dict['record_file']}' for bin."
    fi
    for bin_name in "${bin_names[@]}"
    do
        # Hardening against Bash 4.2 empty array weirdness here.
        [[ -n "$bin_name" ]] || continue
        [[ -f "${dict['libexec']}/bin/${bin_name}" ]] || continue
        _koopa_ln \
            "${dict['libexec']}/bin/${bin_name}" \
            "${dict['prefix']}/bin/${bin_name}"
    done
    if _koopa_is_array_non_empty "${man1_names[@]:-}"
    then
        for man1_name in "${man1_names[@]}"
        do
            # Hardening against Bash 4.2 empty array weirdness here.
            [[ -n "$man1_name" ]] || continue
            [[ -f "${dict['libexec']}/share/man/man1/${man1_name}" ]] \
                || continue
            _koopa_ln \
                "${dict['libexec']}/share/man/man1/${man1_name}" \
                "${dict['prefix']}/share/man/man1/${man1_name}"
        done
    fi
    return 0
}

_koopa_install_ruby_package() {
    # """
    # Install Ruby package.
    # @note Updated 2023-08-29.
    #
    # Alternative approach using gem:
    # > "${app['gem']}" install \
    # >     "${dict['name']}" \
    # >     --version "${dict['version']}" \
    # >     --install-dir "${dict['prefix']}"
    #
    # @seealso
    # - 'gem pristine --all'
    # - 'gem update --system'
    # - https://bundler.io/bundle_install.html
    # - https://textplain.org/p/ruby-isolated-environments
    # - https://dan.carley.co/blog/2012/02/07/rbenv-and-bundler/
    # - https://coderwall.com/p/rz7sqa/keeping-your-bundler-gems-isolated
    # - https://bundler.io/man/bundle-pristine.1.html
    # - https://www.justinweiss.com/articles/3-quick-gem-tricks/
    # - https://stackoverflow.com/questions/16098757/
    # """
    local -A app dict
    _koopa_assert_is_install_subshell
    app['bundle']="$(_koopa_locate_bundle)"
    app['ruby']="$(_koopa_locate_ruby --realpath)"
    _koopa_assert_is_executable "${app[@]}"
    dict['gemfile']='Gemfile'
    dict['jobs']="$(_koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    read -r -d '' "dict[gemfile_string]" << END || true
source "https://rubygems.org"
gem "${dict['name']}", "${dict['version']}"
END
    dict['libexec']="${dict['prefix']}/libexec"
    _koopa_mkdir "${dict['libexec']}"
    _koopa_print_env
    (
        _koopa_cd "${dict['libexec']}"
        _koopa_write_string \
            --file="${dict['gemfile']}" \
            --string="${dict['gemfile_string']}"
        "${app['bundle']}" install \
            --gemfile="${dict['gemfile']}" \
            --jobs="${dict['jobs']}" \
            --retry=3 \
            --standalone
        "${app['bundle']}" binstubs \
            "${dict['name']}" \
            --path="${dict['prefix']}/bin" \
            --shebang="${app['ruby']}" \
            --standalone
    )
    return 0
}

# NOTE How to disable version update notice?
# NOTE How to save 'man1', 'man3' to 'share/man' instead of 'man'?

_koopa_install_perl_package() {
    # """
    # Install Perl package.
    # @note Updated 2023-08-29.
    #
    # Confirm library configuration with 'perl -V' and check '@INC' variable.
    #
    # @section ack installation:
    #
    # File::Next is required for ack.
    # https://github.com/beyondgrep/ack2/issues/459
    #
    # @seealso
    # - https://www.cpan.org/modules/INSTALL.html
    # - https://perldoc.perl.org/ExtUtils::MakeMaker
    # - https://metacpan.org/pod/local::lib
    # - https://www.perl.com/article/4/2013/3/27/
    #     How-to-install-a-specific-version-of-a-Perl-module-with-CPAN/
    # - https://stackoverflow.com/questions/18458194/
    # - https://stackoverflow.com/questions/41527057/
    # - https://kb.iu.edu/d/baiu
    # - http://alumni.soe.ucsc.edu/~you/notes/perl-module-install.html
    # - https://docstore.mik.ua/orelly/weblinux2/modperl/ch03_09.htm
    # - https://blogs.iu.edu/ncgas/2019/05/30/installing-perl-modules-locally/
    # - https://stackoverflow.com/questions/540640/
    # """
    local -A app dict
    local -a bin_files deps
    local bin_file
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'perl'
    _koopa_activate_ca_certificates
    app['bash']="$(_koopa_locate_bash)"
    app['bzip2']="$(_koopa_locate_bzip2)"
    app['cpan']="$(_koopa_locate_cpan)"
    app['gpg']="$(_koopa_locate_gpg)"
    app['gzip']="$(_koopa_locate_gzip)"
    app['less']="$(_koopa_locate_less)"
    app['make']="$(_koopa_locate_make)"
    app['patch']="$(_koopa_locate_patch)"
    app['perl']="$(_koopa_locate_perl)"
    app['tar']="$(_koopa_locate_tar)"
    app['unzip']="$(_koopa_locate_unzip)"
    app['wget']="$(_koopa_locate_wget)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cpan_path']=''
    dict['jobs']="$(_koopa_cpu_count)"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['tmp_cpan']="$(_koopa_init_dir 'cpan')"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    deps=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--cpan-path='*)
                dict['cpan_path']="${1#*=}"
                shift 1
                ;;
            '--cpan-path')
                dict['cpan_path']="${2:?}"
                shift 2
                ;;
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--cpan-path' "${dict['cpan_path']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    dict['cpan_config_file']="${dict['tmp_cpan']}/CPAN/MyConfig.pm"
    read -r -d '' "dict[cpan_config_string]" << END || true
\$CPAN::Config = {
  'allow_installing_module_downgrades' => q[no],
  'allow_installing_outdated_dists' => q[yes],
  'applypatch' => q[],
  'auto_commit' => q[0],
  'build_cache' => q[100],
  'build_dir' => q[${dict['tmp_cpan']}/build],
  'build_dir_reuse' => q[0],
  'build_requires_install_policy' => q[yes],
  'bzip2' => q[${app['bzip2']}],
  'cache_metadata' => q[0],
  'check_sigs' => q[0],
  'cleanup_after_install' => q[1],
  'colorize_output' => q[0],
  'commandnumber_in_prompt' => q[1],
  'connect_to_internet_ok' => q[1],
  'cpan_home' => q[${dict['tmp_cpan']}],
  'ftp_passive' => q[1],
  'ftp_proxy' => q[],
  'getcwd' => q[cwd],
  'gpg' => q[${app['gpg']}],
  'gzip' => q[${app['gzip']}],
  'halt_on_failure' => q[1],
  'histfile' => q[${dict['tmp_cpan']}/histfile],
  'histsize' => q[100],
  'http_proxy' => q[],
  'inactivity_timeout' => q[0],
  'index_expire' => q[1],
  'inhibit_startup_message' => q[1],
  'keep_source_where' => q[${dict['tmp_cpan']}/sources],
  'load_module_verbosity' => q[v],
  'make' => q[${app['make']}],
  'make_arg' => q[-j${dict['jobs']}],
  'make_install_arg' => q[-j${dict['jobs']}],
  'make_install_make_command' => q[${app['make']}],
  'makepl_arg' => q[INSTALL_BASE=${dict['prefix']}],
  'mbuild_arg' => q[],
  'mbuild_install_arg' => q[],
  'mbuild_install_build_command' => q[./Build],
  'mbuildpl_arg' => q[--install_base ${dict['prefix']}],
  'no_proxy' => q[],
  'pager' => q[${app['less']} -R],
  'patch' => q[${app['patch']}],
  'perl5lib_verbosity' => q[v],
  'prefer_external_tar' => q[1],
  'prefer_installer' => q[MB],
  'prefs_dir' => q[${dict['tmp_cpan']}/prefs],
  'prerequisites_policy' => q[follow],
  'pushy_https' => q[1],
  'recommends_policy' => q[1],
  'scan_cache' => q[never],
  'shell' => q[${app['bash']}],
  'show_unparsable_versions' => q[0],
  'show_upload_date' => q[0],
  'show_zero_versions' => q[0],
  'suggests_policy' => q[0],
  'tar' => q[${app['tar']}],
  'tar_verbosity' => q[vv],
  'term_is_latin' => q[1],
  'term_ornaments' => q[1],
  'test_report' => q[0],
  'trust_test_report_history' => q[0],
  'unzip' => q[${app['unzip']}],
  'urllist' => [q[http://www.cpan.org/]],
  'use_prompt_default' => q[1],
  'use_sqlite' => q[0],
  'version_timeout' => q[15],
  'wget' => q[${app['wget']}],
  'yaml_load_code' => q[0],
  'yaml_module' => q[YAML],
};
1;
__END__
END
    _koopa_write_string \
        --file="${dict['cpan_config_file']}" \
        --string="${dict['cpan_config_string']}"
    dict['perl_ver']="$(_koopa_get_version "${app['perl']}")"
    dict['perl_maj_ver']="$(_koopa_major_version "${dict['perl_ver']}")"
    dict['lib_prefix']="${dict['prefix']}/lib/perl${dict['perl_maj_ver']}"
    export PERL5LIB="${dict['lib_prefix']}"
    _koopa_print_env
    if _koopa_is_array_non_empty "${deps[@]:-}"
    then
        "${app['cpan']}" \
            -j "${dict['cpan_config_file']}" \
            "${deps[@]}"
    fi
    "${app['cpan']}" \
        -j "${dict['cpan_config_file']}" \
        "${dict['cpan_path']}-${dict['version']}.tar.gz"
    _koopa_assert_is_dir "${dict['lib_prefix']}"
    # Ensure we burn Perl library path into executables.
    dict['lib_string']="use lib \"${dict['lib_prefix']}\";"
    readarray -t bin_files <<< "$( \
        _koopa_find \
            --max-depth=1 \
            --min-depth=1 \
            --prefix="${dict['prefix']}/bin" \
            --type='f' \
    )"
    _koopa_assert_is_array_non_empty "${bin_files[@]:-}"
    _koopa_assert_is_file "${bin_files[@]}"
    for bin_file in "${bin_files[@]}"
    do
        _koopa_insert_at_line_number \
            --file="$bin_file" \
            --line-number=2 \
            --string="${dict['lib_string']}"
    done
    return 0
}

# FIXME This needs to set http_proxy if defined.

_koopa_install_haskell_package() {
    # """
    # Install a Haskell package using Cabal and GHCup.
    # @note Updated 2024-07-08.
    #
    # @seealso
    # - https://www.haskell.org/ghc/
    # - https://www.haskell.org/cabal/
    # - https://www.haskell.org/ghcup/
    # - https://hackage.haskell.org/
    # - https://cabal.readthedocs.io/
    # - https://cabal.readthedocs.io/en/latest/nix-local-build-overview.html
    # - https://cabal.readthedocs.io/en/stable/cabal-project.html
    # """
    local -A app dict
    local -a build_deps conf_args deps extra_pkgs install_args
    local dep
    _koopa_assert_is_install_subshell
    build_deps=('git' 'pkg-config')
    _koopa_activate_app --build-only "${build_deps[@]}"
    app['cabal']="$(_koopa_locate_cabal)"
    app['ghcup']="$(_koopa_locate_ghcup)"
    _koopa_assert_is_executable "${app[@]}"
    dict['cabal_dir']="$(_koopa_init_dir 'cabal')"
    dict['ghc_version']='9.4.7'
    dict['ghcup_prefix']="$(_koopa_init_dir 'ghcup')"
    dict['jobs']="$(_koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['cabal_store_dir']="$(\
        _koopa_init_dir "${dict['prefix']}/libexec/cabal/store" \
    )"
    deps=()
    extra_pkgs=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--dependency='*)
                deps+=("${1#*=}")
                shift 1
                ;;
            '--dependency')
                deps+=("${2:?}")
                shift 2
                ;;
            '--extra-package='*)
                extra_pkgs+=("${1#*=}")
                shift 1
                ;;
            '--extra-package')
                extra_pkgs+=("${2:?}")
                shift 2
                ;;
            '--ghc-version='*)
                dict['ghc_version']="${1#*=}"
                shift 1
                ;;
            '--ghc-version')
                dict['ghc_version']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--ghc-version' "${dict['ghc_version']}" \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    dict['ghc_prefix']="$(_koopa_init_dir "ghc-${dict['ghc_version']}")"
    export CABAL_DIR="${dict['cabal_dir']}"
    export GHCUP_INSTALL_BASE_PREFIX="${dict['ghcup_prefix']}"
    _koopa_print_env
    "${app['ghcup']}" install \
        'ghc' "${dict['ghc_version']}" \
            --isolate "${dict['ghc_prefix']}"
    _koopa_assert_is_dir "${dict['ghc_prefix']}/bin"
    dict['bin_prefix']="$(_koopa_init_dir "${dict['prefix']}/bin")"
    _koopa_add_to_path_start \
        "${dict['ghc_prefix']}/bin" \
        "${dict['bin_prefix']}"
    "${app['cabal']}" update
    dict['cabal_config_file']="${dict['cabal_dir']}/config"
    _koopa_assert_is_file "${dict['cabal_config_file']}"
    conf_args+=("store-dir: ${dict['cabal_store_dir']}")
    if _koopa_is_array_non_empty "${deps[@]:-}"
    then
        for dep in "${deps[@]}"
        do
            local -A dict2
            dict2['prefix']="$(_koopa_app_prefix "$dep")"
            _koopa_assert_is_dir \
                "${dict2['prefix']}" \
                "${dict2['prefix']}/include" \
                "${dict2['prefix']}/lib"
            conf_args+=(
                "extra-include-dirs: ${dict2['prefix']}/include"
                "extra-lib-dirs: ${dict2['prefix']}/lib"
            )
        done
    fi
    dict['cabal_config_string']="$(_koopa_print "${conf_args[@]}")"
    _koopa_append_string \
        --file="${dict['cabal_config_file']}" \
        --string="${dict['cabal_config_string']}"
    install_args+=(
        '--install-method=copy'
        "--installdir=${dict['prefix']}/bin"
        "--jobs=${dict['jobs']}"
        '--verbose'
        "${dict['name']}-${dict['version']}"
    )
    if _koopa_is_array_non_empty "${extra_pkgs[@]:-}"
    then
        install_args+=("${extra_pkgs[@]}")
    fi
    "${app['cabal']}" install "${install_args[@]}"
    return 0
}

_koopa_cmake_build() {
    # """
    # Perform a standard CMake build.
    # @note Updated 2023-10-19.
    # """
    local -A app dict
    local -a build_deps cmake_args cmake_std_args pos
    _koopa_assert_has_args "$#"
    build_deps=('cmake')
    app['cmake']="$(_koopa_locate_cmake)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bin_dir']=''
    dict['build_dir']=''
    dict['generator']='Unix Makefiles'
    dict['include_dir']=''
    dict['jobs']="$(_koopa_cpu_count)"
    dict['lib_dir']=''
    dict['prefix']=''
    dict['source_dir']="$(_koopa_realpath "${PWD:?}")"
    cmake_std_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bin-dir='*)
                dict['bin_dir']="${1#*=}"
                shift 1
                ;;
            '--bin-dir')
                dict['bin_dir']="${2:?}"
                shift 2
                ;;
            '--build-dir='*)
                dict['build_dir']="${1#*=}"
                shift 1
                ;;
            '--build-dir')
                dict['build_dir']="${2:?}"
                shift 2
                ;;
            '--include-dir='*)
                dict['include_dir']="${1#*=}"
                shift 1
                ;;
            '--include-dir')
                dict['include_dir']="${2:?}"
                shift 2
                ;;
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--lib-dir='*)
                dict['lib_dir']="${1#*=}"
                shift 1
                ;;
            '--lib-dir')
                dict['lib_dir']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--source-dir='*)
                dict['source_dir']="${1#*=}"
                shift 1
                ;;
            '--source-dir')
                dict['source_dir']="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--ninja')
                dict['generator']='Ninja'
                shift 1
                ;;
            # Configuration passthrough support --------------------------------
            '-D'*)
                pos+=("$1")
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    _koopa_assert_is_set \
        '--prefix' "${dict['prefix']}" \
        '--source-dir' "${dict['source_dir']}"
    _koopa_assert_is_dir "${dict['source_dir']}"
    if [[ -z "${dict['build_dir']}" ]]
    then
        dict['build_dir']="${dict['source_dir']}-cmake-$(_koopa_random_string)"
    fi
    dict['build_dir']="$(_koopa_init_dir "${dict['build_dir']}")"
    cmake_std_args+=("--prefix=${dict['prefix']}")
    if [[ -n "${dict['bin_dir']}" ]]
    then
        cmake_std_args+=("--bin-dir=${dict['bin_dir']}")
    fi
    if [[ -n "${dict['include_dir']}" ]]
    then
        cmake_std_args+=("--include-dir=${dict['include_dir']}")
    fi
    if [[ -n "${dict['lib_dir']}" ]]
    then
        cmake_std_args+=("--lib-dir=${dict['lib_dir']}")
    fi
    readarray -t cmake_args <<< "$(_koopa_cmake_std_args "${cmake_std_args[@]}")"
    [[ "$#" -gt 0 ]] && cmake_args+=("$@")
    case "${dict['generator']}" in
        'Ninja')
            build_deps+=('ninja')
            ;;
        'Unix Makefiles')
            build_deps+=('make')
            ;;
        *)
            _koopa_stop 'Unsupported generator.'
            ;;
    esac
    _koopa_activate_app --build-only "${build_deps[@]}"
    _koopa_print_env
    _koopa_dl \
        'CMake args' "${cmake_args[*]}" \
        'build dir' "${dict['build_dir']}" \
        'source dir' "${dict['source_dir']}"
    "${app['cmake']}" -LH \
        '-B' "${dict['build_dir']}" \
        '-G' "${dict['generator']}" \
        '-S' "${dict['source_dir']}" \
        "${cmake_args[@]}"
    "${app['cmake']}" \
        --build "${dict['build_dir']}" \
        --parallel "${dict['jobs']}"
    "${app['cmake']}" \
        --install "${dict['build_dir']}" \
        --prefix "${dict['prefix']}"
    return 0
}

_koopa_make_build() {
    # """
    # Build with GNU Make.
    # @note Updated 2024-09-17.
    # """
    local -A app dict
    local -a conf_args pos targets
    local target
    _koopa_assert_has_args "$#"
    case "${KOOPA_INSTALL_NAME:?}" in
        'aws-cli')
            # Handle edge-case aws-cli bootstrap.
            app['make']="$(_koopa_locate_make --allow-system)"
            ;;
        'make')
            app['make']="$(_koopa_locate_make --only-system)"
            ;;
        *)
            # > _koopa_activate_app --build-only 'make'
            app['make']="$(_koopa_locate_make)"
            ;;
    esac
    _koopa_assert_is_executable "${app[@]}"
    dict['jobs']="$(_koopa_cpu_count)"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--jobs='*)
                dict['jobs']="${1#*=}"
                shift 1
                ;;
            '--jobs')
                dict['jobs']="${2:?}"
                shift 2
                ;;
            '--target='*)
                targets+=("${1#*=}")
                shift 1
                ;;
            '--target')
                targets+=("${2:?}")
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    # Alternatively, can use '${arr[@]+"${arr[@]}"}' idiom here to support
    # Bash 4.2, which is common on some legacy HPC systems.
    # https://stackoverflow.com/questions/7577052
    if _koopa_is_array_empty "${targets[@]:-}"
    then
        targets+=('install')
    fi
    conf_args+=("$@")
    _koopa_print_env
    _koopa_dl 'configure args' "${conf_args[*]}"
    _koopa_assert_is_executable './configure'
    ./configure --help || true
    ./configure "${conf_args[@]}"
    "${app['make']}" VERBOSE=1 --jobs="${dict['jobs']}"
    for target in "${targets[@]}"
    do
        "${app['make']}" "$target"
    done
    return 0
}

_koopa_build_go_package() {
    # """
    # Build a Go package using 'go build'.
    # @note Updated 2023-12-22.
    # """
    local -A app dict
    local -a build_args
    _koopa_assert_is_install_subshell
    _koopa_activate_app --build-only 'go'
    app['go']="$(_koopa_locate_go)"
    _koopa_assert_is_executable "${app[@]}"
    dict['bin_name']=''
    dict['build_cmd']=''
    dict['gocache']="$(_koopa_init_dir 'gocache')"
    dict['gopath']="$(_koopa_init_dir 'go')"
    dict['ldflags']=''
    dict['mod']=''
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['tags']=''
    dict['url']=''
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--bin-name='*)
                dict['bin_name']="${1#*=}"
                shift 1
                ;;
            '--bin-name')
                dict['bin_name']="${2:?}"
                shift 2
                ;;
            '--build-cmd='*)
                dict['build_cmd']="${1#*=}"
                shift 1
                ;;
            '--build-cmd')
                dict['build_cmd']="${2:?}"
                shift 2
                ;;
            '--ldflags='*)
                dict['ldflags']="${1#*=}"
                shift 1
                ;;
            '--ldflags')
                dict['ldflags']="${2:?}"
                shift 2
                ;;
            '--mod='*)
                dict['mod']="${1#*=}"
                shift 1
                ;;
            '--mod')
                dict['mod']="${2:?}"
                shift 2
                ;;
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--tags='*)
                dict['tags']="${1#*=}"
                shift 1
                ;;
            '--tags')
                dict['tags']="${2:?}"
                shift 2
                ;;
            '--url='*)
                dict['url']="${1#*=}"
                shift 1
                ;;
            '--url')
                dict['url']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--url' "${dict['url']}" \
        '--version' "${dict['version']}"
    export GOBIN="${dict['prefix']}/bin"
    export GOCACHE="${dict['gocache']}"
    export GOPATH="${dict['gopath']}"
    [[ -z "${dict['bin_name']}" ]] && dict['bin_name']="${dict['name']}"
    if [[ -n "${dict['ldflags']}" ]]
    then
        build_args+=('-ldflags' "${dict['ldflags']}")
    fi
    if [[ -n "${dict['mod']}" ]]
    then
        build_args+=('-mod' "${dict['mod']}")
    fi
    if [[ -n "${dict['tags']}" ]]
    then
        build_args+=('-tags' "${dict['tags']}")
    fi
    build_args+=('-o' "${dict['prefix']}/bin/${dict['bin_name']}")
    if [[ -n "${dict['build_cmd']}" ]]
    then
        build_args+=("${dict['build_cmd']}")
    fi
    _koopa_download "${dict['url']}"
    _koopa_extract "$(_koopa_basename "${dict['url']}")" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    _koopa_dl 'go build args' "${build_args[*]}"
    "${app['go']}" build "${build_args[@]}"
    _koopa_chmod --recursive 'u+rw' "${dict['gopath']}"
    return 0
}
