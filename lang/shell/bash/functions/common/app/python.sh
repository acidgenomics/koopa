#!/usr/bin/env bash

koopa_configure_python() { #{{{1
    # """
    # Configure Python.
    # @note Updated 2021-11-30.
    #
    # This creates a Python 'site-packages' directory and then links using
    # a 'koopa.pth' file into the Python system 'site-packages'.
    #
    # @seealso
    # > "$python" -m site
    # """
    local app dict
    declare -A app=(
        [python]="${1:-}"
    )
    if [[ -z "${app[python]}" ]]
    then
        app[python]="$(koopa_locate_python)"
    fi
    koopa_assert_is_installed "${app[python]}"
    declare -A dict=(
        [version]="$(koopa_get_version "${app[python]}")"
    )
    dict[sys_site_pkgs]="$( \
        koopa_python_system_packages_prefix "${app[python]}" \
    )"
    dict[k_site_pkgs]="$(koopa_python_packages_prefix "${dict[version]}")"
    dict[pth_file]="${dict[sys_site_pkgs]}/koopa.pth"
    koopa_alert "Adding '${dict[pth_file]}' path file."
    if koopa_is_koopa_app "${app[python]}"
    then
        app[write_string]='koopa_write_string'
    else
        app[write_string]='koopa_sudo_write_string'
    fi
    "${app[write_string]}" \
        --file="${dict[pth_file]}" \
        --string="${dict[k_site_pkgs]}"
    koopa_configure_app_packages \
        --name-fancy='Python' \
        --name='python' \
        --prefix="${dict[k_site_pkgs]}"
    return 0
}

koopa_python_activate_venv() { # {{{1
    # """
    # Activate Python virtual environment.
    # @note Updated 2022-03-30.
    #
    # Note that we're using this instead of conda as our default interactive
    # Python environment, so we can easily use pip.
    #
    # Here's how to write a function to detect virtual environment name:
    # https://stackoverflow.com/questions/10406926
    #
    # Only attempt to autoload for bash or zsh.
    #
    # This needs to be run last, otherwise PATH can get messed upon
    # deactivation, due to venv's current poor approach via '_OLD_VIRTUAL_PATH'.
    #
    # Refer to 'declare -f deactivate' for function source code.
    #
    # @examples
    # > koopa_python_activate_venv 'r-reticulate'
    # """
    local dict
    koopa_assert_has_args_eq "$#" 1
    declare -A dict=(
        [active_env]="${VIRTUAL_ENV:-}"
        [name]="${1:?}"
        [nounset]="$(koopa_boolean_nounset)"
        [prefix]="$(koopa_python_virtualenvs_prefix)"
    )
    dict[script]="${dict[prefix]}/${dict[name]}/bin/activate"
    koopa_assert_is_readable "${dict[script]}"
    if [[ -n "${dict[active_env]}" ]]
    then
        koopa_python_deactivate_venv "${dict[active_env]}"
    fi
    [[ "${dict[nounset]}" -eq 1 ]] && set +o nounset
    # shellcheck source=/dev/null
    source "${dict[script]}"
    [[ "${dict[nounset]}" -eq 1 ]] && set -o nounset
    return 0
}

# FIXME Consider adding support for linkage of useful programs directly into
# '/opt/koopa/bin' from here.

koopa_python_create_venv() { # {{{1
    # """
    # Create Python virtual environment.
    # @note Updated 2022-03-30.
    #
    # @seealso
    # - https://docs.python.org/3/library/venv.html
    # - https://github.com/Homebrew/brew/blob/master/docs/
    #     Python-for-Formula-Authors.md
    #
    # @examples
    # > koopa_python_create_venv --name='pandas' 'pandas'
    # """
    local app dict pkgs pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [name]=''
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
                shift 2
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
    pkgs=("$@")
    koopa_assert_is_set --python "${app[python]}"
    koopa_assert_is_installed "${app[python]}"
    dict[py_version]="$(koopa_get_version "${app[python]}")"
    dict[py_maj_min_ver]="$(koopa_major_minor_version "${dict[py_version]}")"
    if [[ -z "${dict[prefix]}" ]]
    then
        koopa_assert_is_set --name "${dict[name]}"
        dict[venv_prefix]="$(koopa_python_virtualenvs_prefix)"
        dict[prefix]="${dict[venv_prefix]}/${dict[name]}"
        dict[app_bn]="$(koopa_basename "${dict[venv_prefix]}")"
        dict[app_prefix]="$(koopa_app_prefix)/${dict[app_bn]}/\
${dict[py_maj_min_ver]}"
        if [[ ! -d "${dict[app_prefix]}" ]]
        then
            koopa_alert "Configuring venv prefix at '${dict[app_prefix]}'."
            koopa_sys_mkdir "${dict[app_prefix]}"
            koopa_sys_set_permissions "$(koopa_dirname "${dict[app_prefix]}")"
        fi
        koopa_link_app_in_opt "${dict[app_prefix]}" "${dict[app_bn]}"
    fi
    [[ -d "${dict[prefix]}" ]] && koopa_sys_rm "${dict[prefix]}"
    koopa_assert_is_not_dir "${dict[prefix]}"
    koopa_sys_mkdir "${dict[prefix]}"
    unset -v PYTHONPATH
    "${app[python]}" -m venv \
        --system-site-packages \
        --without-pip \
        "${dict[prefix]}"
    app[venv_python]="${dict[prefix]}/bin/python${dict[py_maj_min_ver]}"
    koopa_assert_is_installed "${app[venv_python]}"
    koopa_python_pip_install --python="${app[venv_python]}" "${pkgs[@]}"
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    return 0
}

koopa_python_create_venv_r_reticulate() { # {{{1
    # """
    # Create Python virtual environment for reticulate in R.
    # @note Updated 2022-02-23.
    #
    # macOS compiler flags:
    # These flags are now required for scikit-learn to compile, which now
    # requires OpenMP that is unsupported by system default gcc alias.
    #
    # @seealso
    # - https://github.com/scikit-learn/scikit-learn/issues/13371
    # - https://scikit-learn.org/dev/developers/advanced_installation.html
    # """
    local pkgs
    pkgs=(
        'numpy==1.22.1'
        'pandas==1.3.5'
        'scikit-learn==1.0.2'
        'scipy==1.7.3'
    )
    if koopa_is_macos
    then
        local cflags cppflags cxxflags dyld_library_path ldflags
        cflags=(
            "${CFLAGS:-}"
            '-I/usr/local/opt/libomp/include'
            # Don't treat these warnings as errors on macOS with clang.
            # https://github.com/scikit-image/scikit-image/
            #   issues/5051#issuecomment-729795085
            '-Wno-implicit-function-declaration'
        )
        cppflags=(
            "${CPPFLAGS:-}"
            '-Xpreprocessor'
            '-fopenmp'
        )
        cxxflags=(
            "${CXXFLAGS:-}"
            '-I/usr/local/opt/libomp/include'
        )
        dyld_library_path=(
            "${DYLD_LIBRARY_PATH:-}"
            '/usr/local/opt/libomp/lib'
        )
        ldflags=(
            "${LDFLAGS:-}"
            '-L/usr/local/opt/libomp/lib'
            '-lomp'
        )
        export CC='/usr/bin/clang'
        export CXX='/usr/bin/clang++'
        export CFLAGS="${cflags[*]}"
        export CPPFLAGS="${cppflags[*]}"
        export CXXFLAGS="${cxxflags[*]}"
        export DYLD_LIBRARY_PATH="${dyld_library_path[*]}"
        export LDFLAGS="${ldflags[*]}"
        koopa_dl \
            'CC' "${CC:-}" \
            'CFLAGS' "${CFLAGS:-}" \
            'CPPFLAGS' "${CPPFLAGS:-}" \
            'CXX' "${CXX:-}" \
            'CXXFLAGS' "${CXXFLAGS:-}" \
            'DYLD_LIBRARY_PATH' "${DYLD_LIBRARY_PATH:-}" \
            'LDFLAGS' "${LDFLAGS:-}"
    fi
    koopa_python_create_venv --name='r-reticulate' "${pkgs[@]}" "$@"
    return 0
}

koopa_python_deactivate_venv() { # {{{1
    # """
    # Deactivate Python virtual environment.
    # @note Updated 2022-02-16.
    # """
    local dict
    declare -A dict=(
        [prefix]="${VIRTUAL_ENV:-}"
    )
    if [[ -z "${dict[prefix]}" ]]
    then
        koopa_stop 'Python virtual environment is not active.'
    fi
    koopa_remove_from_path "${dict[prefix]}/bin"
    unset -v VIRTUAL_ENV
    return 0
}

koopa_python_get_pkg_versions() {
    # """
    # Get pinned Python package versions for pip install call.
    # @note Updated 2022-01-20.
    # """
    local i pkg pkgs pkg_lower version
    koopa_assert_has_args "$#"
    pkgs=("$@")
    for i in "${!pkgs[@]}"
    do
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa_lowercase "$pkg")"
        version="$(koopa_variable "python-${pkg_lower}")"
        pkgs[$i]="${pkg}==${version}"
    done
    koopa_print "${pkgs[@]}"
    return 0
}

koopa_python_pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2022-03-30.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # - https://github.com/pypa/pip/issues/3828
    # - https://github.com/pypa/pip/issues/8063
    # """
    local app dict dl_args pkgs pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
                shift 2
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
    pkgs=("$@")
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        '--disable-pip-version-check'
        '--no-warn-script-location'
    )
    dl_args=(
        'Python' "${app[python]}"
        'Packages' "$(koopa_to_string "${pkgs[*]}")"
    )
    if [[ -n "${dict[prefix]}" ]]
    then
        install_args+=(
            "--target=${dict[prefix]}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict[prefix]}")
    fi
    koopa_dl "${dl_args[@]}"
    # > unset -v PYTHONPATH
    export PIP_REQUIRE_VIRTUALENV='false'
    # The pip '--isolated' flag ignores the user 'pip.conf' file.
    "${app[python]}" -m pip --isolated \
        install "${install_args[@]}" "${pkgs[@]}"
    return 0
}

koopa_python_pip_outdated() { # {{{1
    # """
    # List oudated pip packages.
    # @note Updated 2022-01-20.
    #
    # Requesting 'freeze' format will return '<pkg>==<version>'.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_list/
    # """
    local app dict
    declare -A app=(
        [python]="${1:-}"
    )
    [[ -z "${app[python]}" ]] && app[python]="$(koopa_locate_python)"
    koopa_assert_is_installed "${app[python]}"
    declare -A dict=(
        [version]="$(koopa_get_version "${app[python]}")"
    )
    dict[prefix]="$(koopa_python_packages_prefix "${dict[version]}")"
    dict[str]="$( \
        "${app[python]}" -m pip list \
            --format 'freeze' \
            --outdated \
            --path "${dict[prefix]}" \
    )"
    [[ -n "${dict[str]}" ]] || return 0
    koopa_print "${dict[str]}"
    return 0
}
