#!/usr/bin/env bash

# TODO Consider erroring if compiler is too old (e.g. GCC 4).
# We should run compiler checks before allowing the install to proceed.

# TODO Need to check that app is supported by parsing app.json file with
# Python, instead of just checking if function is defined in Bash library.
# We may be able to define this as 'koopa_is_app_supported'.
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
# TODO We need to add a trap so the installer cleans up on failure.

koopa_install_app() {
    # """
    # Install application in a versioned directory structure.
    # @note Updated 2024-12-04.
    #
    # Refer to 'locale' for desired LC settings.
    #
    # @seealso
    # - https://stackoverflow.com/questions/692000/
    # """
    local -A app bool dict
    local -a bash_vars bin_arr env_vars man1_arr path_arr pos
    local i
    koopa_assert_has_args "$#"
    koopa_check_build_system
    # When enabled, this will change permissions on the top level directory
    # of the automatically generated prefix.
    bool['auto_prefix']=0
    # Download pre-built binary from our S3 bucket. Inspired by the
    # Homebrew bottle approach.
    bool['binary']=0
    koopa_can_install_binary && bool['binary']=1
    # Install shared apps in bootstrap mode?
    bool['bootstrap']=0
    # Should we copy the log files into the install prefix?
    bool['copy_log_files']=0
    # Automatically install required dependencies (shared apps only).
    bool['deps']=1
    # Allow current environment variables to pass through for compiltion.
    bool['inherit_env']=0
    # When Lmod modules are active, ensure we inherit environment variables.
    koopa_is_lmod_active && bool['inherit_env']=1
    # Perform the installation in an isolated subshell?
    bool['isolate']=1
    # Will any individual programs be linked into koopa 'bin/'?
    bool['link_in_bin']=''
    # Link corresponding man1 documentation files for app in bin.
    bool['link_in_man1']=''
    # Create an unversioned symlink in koopa 'opt/' directory.
    bool['link_in_opt']=''
    # This override is useful for app packages configuration.
    bool['prefix_check']=1
    # Whether current user has access to our private AWS S3 bucket.
    bool['private']=0
    # Push completed build to AWS S3 bucket (shared apps only).
    bool['push']=0
    koopa_can_push_binary && bool['push']=1
    # This is useful for avoiding duplicate alert messages inside of
    # nested install calls (e.g. Emacs installer handoff to GNU app).
    bool['quiet']=0
    bool['reinstall']=0
    bool['update_ldconfig']=0
    bool['verbose']=0
    dict['app_prefix']="$(koopa_app_prefix)"
    dict['cpu_count']="$(koopa_cpu_count)"
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
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_set '--name' "${dict['name']}"
    if [[ "${bool['verbose']}" -eq 1 ]]
    then
        export KOOPA_VERBOSE=1
        set -o xtrace
    fi
    [[ "${dict['mode']}" != 'shared' ]] && bool['deps']=0
    [[ -z "${dict['version_key']}" ]] && dict['version_key']="${dict['name']}"
    dict['current_version']="$(\
        koopa_app_json_version "${dict['version_key']}" 2>/dev/null || true \
    )"
    [[ -z "${dict['version']}" ]] && \
        dict['version']="${dict['current_version']}"
    case "${dict['mode']}" in
        'shared')
            koopa_assert_is_owner
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
            if [[ "${dict['version']}" != "${dict['current_version']}" ]]
            then
                bool['link_in_bin']=0
                bool['link_in_man1']=0
                bool['link_in_opt']=0
            else
                [[ -z "${bool['link_in_bin']}" ]] && bool['link_in_bin']=1
                [[ -z "${bool['link_in_man1']}" ]] && bool['link_in_man1']=1
                [[ -z "${bool['link_in_opt']}" ]] && bool['link_in_opt']=1
            fi
            ;;
        'system')
            koopa_assert_is_owner
            koopa_assert_is_admin
            bool['isolate']=0
            bool['link_in_bin']=0
            bool['link_in_man1']=0
            bool['link_in_opt']=0
            bool['prefix_check']=0
            bool['push']=0
            koopa_is_linux && bool['update_ldconfig']=1
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
        koopa_assert_has_private_access
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ "${bool['prefix_check']}" -eq 1 ]]
    then
        if [[ -d "${dict['prefix']}" ]]
        then
            if [[ ! -f "${dict['prefix']}/.koopa-install-stdout.log" ]]
            then
                bool['reinstall']=1
            fi
            if [[ "${bool['reinstall']}" -eq 1 ]]
            then
                [[ "${bool['quiet']}" -eq 0 ]] && \
                    koopa_alert_uninstall_start \
                        "${dict['name']}" "${dict['prefix']}"
                case "${dict['mode']}" in
                    'system')
                        koopa_rm --sudo "${dict['prefix']}"
                        ;;
                    *)
                        koopa_rm "${dict['prefix']}"
                        ;;
                esac
            fi
            [[ -d "${dict['prefix']}" ]] && return 0
        fi
    fi
    if [[ "${bool['deps']}" -eq 1 ]]
    then
        local dep deps
        readarray -t deps <<< "$(koopa_app_dependencies "${dict['name']}")"
        if koopa_is_array_non_empty "${deps[@]:-}"
        then
            koopa_dl \
                "${dict['name']} dependencies" \
                "$(koopa_to_string "${deps[@]}")"
            for dep in "${deps[@]}"
            do
                local -a dep_install_args
                if [[ -d "$(koopa_app_prefix --allow-missing "$dep")" ]]
                then
                    continue
                fi
                dep_install_args=()
                if [[ "${bool['bootstrap']}" -eq 1 ]]
                then
                    dep_install_args+=('--bootstrap')
                fi
                if [[ "${bool['verbose']}" -eq 1 ]]
                then
                    dep_install_args+=('--verbose')
                fi
                dep_install_args+=("$dep")
                koopa_cli_install "${dep_install_args[@]}"
            done
        fi
    fi
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        koopa_alert_install_start "${dict['name']}" "${dict['prefix']}"
    fi
    if [[ -n "${dict['prefix']}" ]] && [[ ! -d "${dict['prefix']}" ]]
    then
        case "${dict['mode']}" in
            'system')
                dict['prefix']="$(koopa_init_dir --sudo "${dict['prefix']}")"
                ;;
            *)
                dict['prefix']="$(koopa_init_dir "${dict['prefix']}")"
                ;;
        esac
    fi
    if [[ "${bool['binary']}" -eq 1 ]]
    then
        [[ "${dict['mode']}" == 'shared' ]] || return 1
        [[ -n "${dict['prefix']}" ]] || return 1
        koopa_install_app_from_binary_package "${dict['prefix']}"
    elif [[ "${bool['isolate']}" -eq 0 ]]
    then
        export KOOPA_INSTALL_APP_SUBSHELL=1
        koopa_install_app_subshell \
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
            app['bash']="$(koopa_locate_bash --allow-missing)"
            if [[ ! -x "${app['bash']}" ]]
            then
                if koopa_is_macos
                then
                    app['bash']="$(koopa_locate_bash --allow-bootstrap)"
                else
                    app['bash']="$(koopa_locate_bash --allow-system)"
                fi
            fi
        fi
        app['env']="$(koopa_locate_env --allow-system)"
        app['tee']="$(koopa_locate_tee --allow-system)"
        koopa_assert_is_executable "${app[@]}"
        if [[ "${bool['inherit_env']}" -eq 1 ]]
        then
            dict['path']="${PATH:?}"
            env_vars+=(
                "CC=${CC:-}"
                "CPLUS_INCLUDE_PATH=${CPLUS_INCLUDE_PATH:-}"
                "CXX=${CXX:-}"
                "C_INCLUDE_PATH=${C_INCLUDE_PATH:-}"
                "F77=${F77:-}"
                "FC=${FC:-}"
                "INCLUDE=${INCLUDE:-}"
                "LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}"
                "LIBRARY_PATH=${LIBRARY_PATH:-}"
            )
        else
            path_arr+=('/usr/bin' '/usr/sbin' '/bin' '/sbin')
            dict['path']="$(koopa_paste --sep=':' "${path_arr[@]}")"
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
        if [[ "${dict['mode']}" == 'shared' ]]
        then
            if [[ "${bool['inherit_env']}" -eq 1 ]]
            then
                # FIXME Only set these when defined (see above).
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
                # FIXME Rethink and rework our pkg-config approach here.
                PKG_CONFIG_PATH=''
                app['pkg_config']="$( \
                    koopa_locate_pkg_config --allow-missing --only-system \
                )"
                if [[ -x "${app['pkg_config']}" ]]
                then
                    koopa_activate_pkg_config "${app['pkg_config']}"
                fi
                # Strip '/usr/local' from pkg-config, which requires Perl.
                # FIXME Hitting a regex issue on HPC, so disabling this step to
                # debug further.
                # # Regexp modifiers "/l" and "/a" are mutually exclusive at -e line 1, at end of line
                # # Regexp modifier "/l" may not appear twice at -e line 1, at end of line
                # # syntax error at -e line 1, near "s/\\/usr\\/local["
                # FIXME Rework this as 'koopa_remove_from_pkg_config_path' function.
                # > app['perl']="$(koopa_locate_perl --allow-missing)"
                # > if [[ -x "${app['perl']}" ]]
                # > then
                # >     PKG_CONFIG_PATH="$( \
                # >         koopa_gsub \
                # >             --regex \
                # >             --pattern='/usr/local[^\:]+:' \
                # >             --replacement='' \
                # >             "$PKG_CONFIG_PATH"
                # >     )"
                # > fi
                env_vars+=("PKG_CONFIG_PATH=${PKG_CONFIG_PATH}")
                unset -v PKG_CONFIG_PATH
            fi
            if [[ -d "${dict['prefix']}" ]] && \
                [[ "${dict['mode']}" != 'system' ]]
            then
                bool['copy_log_files']=1
            fi
        fi
        dict['header_file']="$(koopa_bash_prefix)/include/header.sh"
        dict['stderr_file']="$(koopa_tmp_log_file)"
        dict['stdout_file']="$(koopa_tmp_log_file)"
        koopa_assert_is_file \
            "${dict['header_file']}" \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
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
        "${app['env']}" -i \
            "${env_vars[@]}" \
            "${app['bash']}" \
                "${bash_vars[@]}" \
                -c "source '${dict['header_file']}'; \
                    koopa_install_app_subshell \
                        --installer=${dict['installer']} \
                        --mode=${dict['mode']} \
                        --name=${dict['name']} \
                        --platform=${dict['platform']} \
                        --prefix=${dict['prefix']} \
                        --version=${dict['version']} \
                        ${*}" \
            > >("${app['tee']}" "${dict['stdout_file']}") \
            2> >("${app['tee']}" "${dict['stderr_file']}" >&2)
        if [[ "${bool['copy_log_files']}" -eq 1 ]] && \
            [[ -d "${dict['prefix']}" ]]
        then
            koopa_cp \
                "${dict['stdout_file']}" \
                "${dict['prefix']}/.koopa-install-stdout.log"
            koopa_cp \
                "${dict['stderr_file']}" \
                "${dict['prefix']}/.koopa-install-stderr.log"
        fi
        koopa_rm \
            "${dict['stderr_file']}" \
            "${dict['stdout_file']}"
    fi
    case "${dict['mode']}" in
        'shared')
            if [[ "${bool['link_in_opt']}" -eq 1 ]]
            then
                koopa_link_in_opt \
                    --name="${dict['name']}" \
                    --source="${dict['prefix']}"
            fi
            if [[ "${bool['link_in_bin']}" -eq 1 ]]
            then
                readarray -t bin_arr <<< "$( \
                    koopa_app_json_bin "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${bin_arr[@]:-}"
                then
                    for i in "${!bin_arr[@]}"
                    do
                        local -A dict2
                        dict2['name']="${bin_arr[$i]}"
                        dict2['source']="${dict['prefix']}/bin/${dict2['name']}"
                        koopa_link_in_bin \
                            --name="${dict2['name']}" \
                            --source="${dict2['source']}"
                    done
                fi
            fi
            if [[ "${bool['link_in_man1']}" -eq 1 ]]
            then
                readarray -t man1_arr <<< "$( \
                    koopa_app_json_man1 "${dict['name']}" \
                        2>/dev/null || true \
                )"
                if koopa_is_array_non_empty "${man1_arr[@]:-}"
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
                            koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf1']}"
                        elif [[ -f "${dict2['mf2']}" ]]
                        then
                            koopa_link_in_man1 \
                                --name="${dict2['name']}" \
                                --source="${dict2['mf2']}"
                        fi
                    done
                fi
            fi
            if [[ "${bool['push']}" -eq 1 ]]
            then
                koopa_push_app_build "${dict['name']}"
            fi
            ;;
        'system')
            if [[ "${bool['update_ldconfig']}" -eq 1 ]]
            then
                koopa_linux_update_ldconfig
            fi
            ;;
    esac
    if [[ "${bool['quiet']}" -eq 0 ]]
    then
        koopa_alert_install_success "${dict['name']}" "${dict['prefix']}"
    fi
    return 0
}
