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
    # @note Updated 2022-02-16.
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
        [prefix]="$(koopa_python_venv_prefix)"
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

koopa_python_create_venv() { # {{{1
    # """
    # Create Python virtual environment.
    # @note Updated 2022-02-23.
    #
    # @examples
    # > koopa_python_create_venv --name='base'
    # """
    local app default_pkgs dict pos
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [name]=''
        [name_fancy]='Python virtual environment'
        [reinstall]=0
    )
    default_pkgs=('pip' 'setuptools' 'wheel')
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
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--reinstall')
                dict[reinstall]=1
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
    koopa_assert_is_set \
        --name "${dict[name]}" \
        --python "${app[python]}"
    koopa_assert_is_installed "${app[python]}"
    dict[prefix]="$(koopa_python_venv_prefix)/${dict[name]}"
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        koopa_sys_rm "${dict[prefix]}"
    fi
    koopa_alert_install_start "${dict[name_fancy]}" "${dict[prefix]}"
    koopa_assert_is_not_dir "${dict[prefix]}"
    koopa_sys_mkdir "${dict[prefix]}"
    "${app[python]}" -m venv "${dict[prefix]}"
    app[venv_python]="${dict[prefix]}/bin/python3"
    koopa_assert_is_installed "${app[venv_python]}"
    "${app[venv_python]}" -m pip install --upgrade "${default_pkgs[@]}"
    if [[ "$#" -gt 0 ]]
    then
        "${app[venv_python]}" -m pip install --upgrade "$@"
    fi
    koopa_sys_set_permissions --recursive "${dict[prefix]}"
    "${app[venv_python]}" -m pip list
    koopa_alert_install_success "${dict[name_fancy]}" "${dict[prefix]}"
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
    # Usage of '--target' with '--upgrade' will remove existing bin files from
    # other packages that are not updated. This is annoying, but there's no
    # current workaround except to not use '--upgrade'.
    #
    # If you disable '--upgrade', then these warning messages will pop up:
    # > WARNING: Target directory XXX already exists.
    # > Specify --upgrade to force replacement.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # - https://github.com/pypa/pip/issues/3828
    # - https://github.com/pypa/pip/issues/8063
    # """
    local app dict pkgs pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [reinstall]=0
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
            # Flags ------------------------------------------------------------
            '--reinstall')
                dict[reinstall]=1
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
    pkgs=("$@")
    if [[ -z "${dict[prefix]}" ]]
    then
        koopa_configure_python "${app[python]}"
        dict[version]="$(koopa_get_version "${app[python]}")"
        dict[prefix]="$(koopa_python_packages_prefix "${dict[version]}")"
    fi
    koopa_dl \
        'Python' "${app[python]}" \
        'Packages' "$(koopa_to_string "${pkgs[*]}")" \
        'Target' "${dict[prefix]}"
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        "--target=${dict[prefix]}"
        '--disable-pip-version-check'
        '--no-warn-script-location'
        '--upgrade'
    )
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        pip_flags+=(
            '--force-reinstall'
            '--ignore-installed'
        )
    fi
    export PIP_REQUIRE_VIRTUALENV='false'
    # The pip '--isolated' flag ignores the user 'pip.conf' file.
    "${app[python]}" -m pip --isolated install "${install_args[@]}" "${pkgs[@]}"
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
