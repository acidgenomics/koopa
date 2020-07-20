#!/usr/bin/env bash

koopa::install_pip() { # {{{1
    # """
    # Install pip for Python.
    # @note Updated 2020-07-10.
    # """
    local file name pos python reinstall tmp_dir url
    name='pip'
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
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
    koopa::assert_has_args_le "$#" 1
    python="${1:-python3}"
    if ! koopa::is_installed "$python"
    then
        koopa::warning "Python (\"${python}\") is not installed."
        return 1
    fi
    if [[ "$reinstall" -eq 0 ]]
    then
        if koopa::is_python_package_installed --python="$python" "$name"
        then
            koopa::note "Python package \"${name}\" is already installed."
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
    koopa::install_success "$name"
    koopa::restart
    return 0
}

koopa::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2020-07-10.
    # These are used internally by koopa.
    # """
    local install_flags name_fancy pkgs pos python
    python="$(koopa::python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
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
            "black==$(koopa::variable 'python-black')"
            "flake8==$(koopa::variable 'python-flake8')"
            "logbook==$(koopa::variable 'python-logbook')"
            "pip==$(koopa::variable 'python-pip')"
            "pipx==$(koopa::variable 'python-pipx')"
            "pyflakes==$(koopa::variable 'python-pyflakes')"
            "pylint==$(koopa::variable 'python-pylint')"
            "pytest==$(koopa::variable 'python-pytest')"
            "six==$(koopa::variable 'python-six')"
            'setuptools'
            'wheel'
        )
    fi
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    koopa::dl 'Site library' "$(koopa::python_site_packages_prefix)"
    install_flags=()
    [[ "$reinstall" -eq 1 ]] && install_flags+=('--reinstall')
    koopa::install_pip "${install_flags[@]}"
    koopa::pip_install "${install_flags[@]}" "${pkgs[@]}"
    koopa::is_cellar "$python" && koopa::link_cellar python
    koopa::install_success "$name_fancy"
    return 0
}

koopa::pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2020-07-03.
    # """
    local pip_install_flags pos python reinstall
    koopa::assert_has_args "$#"
    python='python3'
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
    koopa::assert_is_python_package_installed --python="$python" 'pip'
    pip_install_flags=('--no-warn-script-location')
    if [[ "$reinstall" -eq 1 ]]
    then
        pip_flags+=(
            '--force-reinstall'
            '--ignore-installed'
        )
    fi
    koopa::dl 'Packages' "$(koopa::to_string "$@")"
    "$python" -m pip install "${pip_install_flags[@]}" "$@"
    return 0
}

koopa::python() { # {{{1
    # """
    # Python executable path.
    # @note Updated 2020-07-13.
    # """
    local python
    python='python3'
    koopa::is_installed "$python" || return 1
    koopa::print "$python"
    return 0
}

koopa::python_remove_pycache() { # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2020-06-30.
    #
    # These directories can create permission issues when attempting to rsync
    # installation across multiple VMs.
    # """
    local prefix python
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed find
    prefix="${1:-}"
    if [[ -z "$prefix" ]]
    then
        # e.g. /usr/local/cellar/python/3.8.1
        python="$(koopa::which_realpath "python3")"
        prefix="$(realpath "$(dirname "$python")/..")"
    fi
    koopa::info "Removing pycache in '${prefix}'."
    # > find "$prefix" \
    # >     -type d \
    # >     -name "__pycache__" \
    # >     -print0 \
    # >     -exec rm -frv "{}" \;
    find "$prefix" \
        -type d \
        -name "__pycache__" \
        -print0 \
        | xargs -0 -I {} rm -frv "{}"
    return 0
}

koopa::venv_create() { # {{{1
    # """
    # Create Python virtual environment.
    # @note Updated 2020-07-02.
    # """
    local name prefix py_exe
    koopa::assert_has_no_envs
    koopa::assert_is_installed python3
    koopa::assert_is_current_version python
    name="${1:?}"
    prefix="$(koopa::venv_prefix)/${name}"
    [[ -d "$prefix" ]] && return 0
    shift 1
    koopa::info "Installing Python '${name}' virtual environment at '${prefix}'."
    koopa::mkdir "$prefix"
    python3 -m venv "$prefix"
    py_exe="${prefix}/bin/python3"
    "$py_exe" -m pip install --upgrade pip setuptools wheel
    if [[ "$#" -gt 0 ]]
    then
        "$py_exe" -m pip install --upgrade "$@"
    elif [[ "$name" != "base" ]]
    then
        "$py_exe" -m pip install "$name"
    fi
    koopa::sys_set_permissions -r "$prefix"
    "$py_exe" -m pip list
    return 0
}

koopa::venv_create_base() { # {{{1
    # """
    # Create base Python virtual environment.
    # @note Updated 2020-07-03.
    # """
    koopa::assert_has_no_args "$#"
    koopa::venv_create "base"
    return 0
}

koopa::venv_create_r_reticulate() { # {{{1
    # """
    # Create Python reticulate environment for R.
    # @note Updated 2020-07-02.
    #
    # Check that LLVM is configured correctly.
    # umap-learn > numba > llvmlite
    # Note that llvmlite currently requires LLVM 7+.
    # https://github.com/numba/llvmlite/issues/523
    #
    # macOS compiler flags:
    # These flags are now required for scikit-learn to compile, which now requires
    # OpenMP that is unsupported by system default gcc alias.
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
    name="r-reticulate"
    packages=(
        Cython
        cwltool
        louvain
        numpy
        pandas
        pip
        pyyaml
        scikit-learn
        scipy
        setuptools
        umap-learn
        wheel
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
        koopa::info "LLVM_CONFIG: \"${LLVM_CONFIG}\"."
    else
        koopa::note 'Export "LLVM_CONFIG" to locate LLVM llvm-config binary.'
    fi
    koopa::venv_create "$name" "${packages[@]}"
    return 0
}
