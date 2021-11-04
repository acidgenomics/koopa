#!/usr/bin/env bash

koopa::python_get_pkg_versions() {
    # """
    # Get pinned Python package versions for pip install call.
    # @note Updated 2021-10-05.
    # """
    local i pkg pkgs pkg_lower version
    koopa::assert_has_args "$#"
    pkgs=("$@")
    for i in "${!pkgs[@]}"
    do
        pkg="${pkgs[$i]}"
        pkg_lower="$(koopa::lowercase "$pkg")"
        version="$(koopa::variable "python-${pkg_lower}")"
        pkgs[$i]="${pkg}==${version}"
    done
    koopa::print "${pkgs[@]}"
    return 0
}

# FIXME Now seeing this error on my MacBook:
# ERROR: Could not find an activated virtualenv (required).

koopa::python_pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2021-11-04.
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # - https://github.com/pypa/pip/issues/3828
    # """
    local app dict pkgs pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa::locate_python)"
    )
    declare -A dict=(
        [reinstall]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    pkgs=("$@")
    koopa::configure_python "${app[python]}"
    dict[version]="$(koopa::get_version "${app[python]}")"
    dict[target]="$(koopa::python_packages_prefix "${dict[version]}")"
    koopa::dl \
        'Python' "${app[python]}" \
        'Packages' "$(koopa::to_string "${pkgs[*]}")" \
        'Target' "${dict[target]}"
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        "--target=${dict[target]}"
        '--disable-pip-version-check'
        '--no-warn-script-location'
        '--progress-bar=pretty'
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

koopa::python_pip_outdated() { # {{{1
    # """
    # List oudated pip packages.
    # @note Updated 2021-10-27.
    #
    # Requesting 'freeze' format will return '<pkg>==<version>'.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_list/
    # """
    local prefix python version x
    python="${1:-}"
    [[ -z "${python:-}" ]] && python="$(koopa::locate_python)"
    version="$(koopa::get_version "$python")"
    prefix="$(koopa::python_packages_prefix "$version")"
    x="$( \
        "$python" -m pip list \
            --format 'freeze' \
            --outdated \
            --path "$prefix" \
    )"
    [[ -n "$x" ]] || return 0
    koopa::print "$x"
    return 0
}

koopa::python_venv_create() { # {{{1
    # """
    # Create Python virtual environment.
    # @note Updated 2021-09-21.
    # """
    local default_pkgs name name_fancy prefix pos python reinstall venv_python
    koopa::assert_has_no_envs
    name_fancy='Python virtual environment'
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                name="${1#*=}"
                shift 1
                ;;
            '--name')
                name="${2:?}"
                shift 2
                ;;
            '--python='*)
                python="${1#*=}"
                shift 1
                ;;
            '--python')
                python="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--force' | \
            '--reinstall')
                reinstall=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    [[ -z "${python:-}" ]] && python="$(koopa::locate_python)"
    koopa::assert_is_installed "$python"
    prefix="$(koopa::python_venv_prefix)/${name}"
    if [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$prefix"
    fi
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "Environment already exists at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::sys_mkdir "$prefix"
    "$python" -m venv "$prefix"
    venv_python="${prefix}/bin/python3"
    default_pkgs=('pip' 'setuptools' 'wheel')
    "$venv_python" -m pip install --upgrade "${default_pkgs[@]}"
    if [[ "$#" -gt 0 ]]
    then
        "$venv_python" -m pip install --upgrade "$@"
    fi
    koopa::sys_set_permissions --recursive "$prefix"
    "$venv_python" -m pip list
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

koopa::python_venv_create_base() { # {{{1
    # """
    # Create base Python virtual environment.
    # @note Updated 2021-07-29.
    # """
    koopa::python_venv_create --name='base' "$@"
    return 0
}

# NOTE Consider pinning this to Python 3.9.
koopa::python_venv_create_r_reticulate() { # {{{1
    # """
    # Create Python virtual environment for reticulate in R.
    # @note Updated 2021-07-29.
    #
    # Check that LLVM is configured correctly.
    # umap-learn > numba > llvmlite
    # Note that llvmlite currently requires LLVM 7+.
    # https://github.com/numba/llvmlite/issues/523
    #
    # macOS compiler flags:
    # These flags are now required for scikit-learn to compile, which now
    # requires OpenMP that is unsupported by system default gcc alias.
    #
    # Ensure that we're using the correct Clang and LLVM settings.
    #
    # Refer to 'system/activate/program.sh' for LLVM_CONFIG export.
    #
    # clang: error: unsupported option '-fopenmp'
    # brew info libomp
    #
    # @seealso
    # - http://llvmlite.pydata.org/
    # - https://github.com/scikit-learn/scikit-learn/issues/13371
    # - https://scikit-learn.org/dev/developers/advanced_installation.html
    # """
    local cflags cppflags cxxflags dyld_library_path ldflags name pkgs
    name='r-reticulate'
    pkgs=(
        # Essential defaults ---------------------------------------------------
        'pip'
        'setuptools'
        'wheel'
        # Other recommended packages -------------------------------------------
        'Cython'
        'PyYAML'
        'leidenalg'         # R leiden
        'numpy'
        'pandas'            # Fails on Python 3.10.
        'python-igraph'     # R leiden
        'scikit-learn'
        'scipy'
        'umap-learn'
    )
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    if koopa::is_macos
    then
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
        koopa::dl \
            'CC' "${CC:-}" \
            'CFLAGS' "${CFLAGS:-}" \
            'CPPFLAGS' "${CPPFLAGS:-}" \
            'CXX' "${CXX:-}" \
            'CXXFLAGS' "${CXXFLAGS:-}" \
            'DYLD_LIBRARY_PATH' "${DYLD_LIBRARY_PATH:-}" \
            'LDFLAGS' "${LDFLAGS:-}"
    fi
    LLVM_CONFIG="$(koopa::locate_llvm_config)"
    koopa::assert_is_executable "$LLVM_CONFIG"
    export LLVM_CONFIG
    koopa::python_venv_create \
        --name="$name" \
        "${pkgs[@]}" \
        "$@"
    return 0
}
