#!/usr/bin/env bash

koopa::install_pip() { # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-07-10.
    # """
    local file name pos python reinstall tmp_dir url
    name='pip'
    python="$(koopa::python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --python)
                python="$2"
                shift 2
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
            '')
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed "$python"
    if [[ "$reinstall" -eq 0 ]]
    then
        if koopa::is_python_package_installed --python="$python" "$name"
        then
            koopa::note "Python package '${name}' is already installed."
            return 0
        fi
    fi
    koopa::install_start "$name"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='get-pip.py'
        url="https://bootstrap.pypa.io/${file}"
        koopa::download "$url"
        "$python" "$file" --no-warn-script-location
    )
    koopa::rm "$tmp_dir"
    koopa::is_cellar "$python" && koopa::link_cellar python
    koopa::install_success "$name"
    return 0
}

koopa::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2020-08-06.
    # """
    local install_flags name_fancy pkg pkgs pos python version
    python="$(koopa::python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --python)
                python="$2"
                shift 2
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
            '')
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_envs
    koopa::assert_is_installed "$python"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            'black'
            'flake8'
            'logbook'
            'pip'
            'pipx'
            'pyflakes'
            'pylint'
            'pytest'
            'ranger-fm'
            'six'
            'setuptools'
            'wheel'
        )
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            version="$(koopa::variable "python-${pkg}")"
            pkgs[$i]="${pkg}==${version}"
        done
    fi
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    install_flags=("--python=${python}")
    [[ "$reinstall" -eq 1 ]] && install_flags+=('--reinstall')
    koopa::python_add_site_packages_to_sys_path "$python"
    koopa::install_pip "${install_flags[@]}"
    koopa::pip_install "${install_flags[@]}" "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2020-08-06.
    # """
    local pip_install_flags pos python reinstall target
    koopa::assert_has_args "$#"
    python="$(koopa::python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --python)
                python="$2"
                shift 2
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
            '')
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_is_installed "$python"
    target="$(koopa::python_site_packages_prefix "$python")"
    koopa::sys_mkdir "$target"
    koopa::dl \
        'Packages' "$(koopa::to_string "$@")" \
        'Target' "$target"
    pip_install_flags=(
        "--target=${target}"
        '--no-warn-script-location'
        '--upgrade'
    )
    if [[ "$reinstall" -eq 1 ]]
    then
        pip_flags+=(
            '--force-reinstall'
            '--ignore-installed'
        )
    fi
    "$python" -m pip install "${pip_install_flags[@]}" "$@"
    return 0
}

koopa::python_add_site_packages_to_sys_path() { # {{{1
    # """
    # Add our custom site packages library to sys.path.
    # @note Updated 2020-08-06.
    #
    # @seealso
    # > "$python" -m site
    # """
    local file k_site_pkgs python sys_site_pkgs
    python="${1:-}"
    [[ -z "$python" ]] && python="$(koopa::python)"
    sys_site_pkgs="$(koopa::python_system_site_packages_prefix "$python")"
    k_site_pkgs="$(koopa::python_site_packages_prefix "$python")"
    [[ ! -d "$k_site_pkgs" ]] && koopa_sys_mkdir "$k_site_pkgs"
    file="${sys_site_pkgs}/koopa.pth"
    [[ -f "$file" ]] && return 0
    koopa::info "Adding '${file}' path file in '${sys_site_pkgs}'."
    if koopa::is_cellar "$python"
    then
        koopa::write_string "$k_site_pkgs" "$file"
    else
        koopa::sudo_write_string "$k_site_pkgs" "$file"
    fi
    return 0
}

koopa::python_remove_pycache() { # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2020-08-06.
    #
    # These directories can create permission issues when attempting to rsync
    # installation across multiple VMs.
    # """
    local pos prefix python
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find
    python="$(koopa::python)"
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --python)
                python="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    python="$(koopa::which_realpath "$python")"
    prefix="$(koopa::parent_dir -n 2 "$python")"
    koopa::info "Removing pycache in '${prefix}'."
    find "$prefix" \
        -type d \
        -name '__pycache__' \
        -print0 \
        | xargs -0 -I {} rm -frv '{}'
    return 0
}

koopa::venv_create() { # {{{1
    # """
    # Create Python virtual environment.
    # @note Updated 2020-07-21.
    # """
    local name prefix python venv_python
    python="$(koopa::python)"
    koopa::assert_has_no_envs
    koopa::assert_is_installed "$python"
    name="${1:?}"
    prefix="$(koopa::venv_prefix)/${name}"
    [[ -d "$prefix" ]] && return 0
    shift 1
    koopa::info "Installing Python '${name}' venv at '${prefix}'."
    koopa::mkdir "$prefix"
    "$python" -m venv "$prefix"
    venv_python="${prefix}/bin/python3"
    "$venv_python" -m pip install --upgrade pip setuptools wheel
    if [[ "$#" -gt 0 ]]
    then
        "$venv_python" -m pip install --upgrade "$@"
    elif [[ "$name" != 'base' ]]
    then
        "$venv_python" -m pip install "$name"
    fi
    koopa::sys_set_permissions -r "$prefix"
    "$venv_python" -m pip list
    return 0
}

koopa::venv_create_base() { # {{{1
    # """
    # Create base Python virtual environment.
    # @note Updated 2020-07-20.
    # """
    koopa::assert_has_no_args "$#"
    koopa::venv_create 'base'
    return 0
}

koopa::venv_create_r_reticulate() { # {{{1
    # """
    # Create Python reticulate environment for R.
    # @note Updated 2020-07-20.
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
    local name packages
    koopa::assert_has_no_args "$#"
    name='r-reticulate'
    packages=(
        'Cython'
        'cwltool'
        'louvain'
        'numpy'
        'pandas'
        'pip'
        'pyyaml'
        'scikit-learn'
        'scipy'
        'setuptools'
        'umap-learn'
        'wheel'
    )
    if koopa::is_macos
    then
        export CC='/usr/bin/clang'
        export CXX='/usr/bin/clang++'
        export CFLAGS="${CFLAGS:-} -I/usr/local/opt/libomp/include"
        export CPPFLAGS="${CPPFLAGS:-} -Xpreprocessor -fopenmp"
        export CXXFLAGS="${CXXFLAGS:-} -I/usr/local/opt/libomp/include"
        export DYLD_LIBRARY_PATH='/usr/local/opt/libomp/lib'
        export LDFLAGS="${LDFLAGS:-} -L/usr/local/opt/libomp/lib -lomp"
    fi
    if [[ -n "${LLVM_CONFIG:-}" ]]
    then
        koopa::info "LLVM_CONFIG: '${LLVM_CONFIG}'."
    else
        koopa::note "Export 'LLVM_CONFIG' to locate LLVM llvm-config binary."
    fi
    koopa::venv_create "$name" "${packages[@]}"
    return 0
}
