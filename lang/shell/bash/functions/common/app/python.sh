#!/usr/bin/env bash

koopa::python_delete_pycache() { # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2021-05-23.
    #
    # These directories can create permission issues when attempting to rsync
    # installation across multiple VMs.
    # """
    local find pos prefix python rm xargs
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed 'find'
    find="$(koopa::locate_find)"
    python="$(koopa::locate_python)"
    rm="$(koopa::locate_rm)"
    xargs="$(koopa::locate_xargs)"
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    python="$(koopa::which_realpath "$python")"
    prefix="$(koopa::parent_dir -n 2 "$python")"
    koopa::alert "Removing pycache in '${prefix}'."
    "$find" "$prefix" \
        -type d \
        -name '__pycache__' \
        -print0 \
        | "$xargs" -0 -I {} "$rm" -fr '{}'
    return 0
}

koopa::python_pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2021-05-25.
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # """
    local install_flags pos python reinstall target
    koopa::assert_has_args "$#"
    python="$(koopa::locate_python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
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
    koopa::configure_python "$python"
    version="$(koopa::get_version "$python")"
    target="$(koopa::python_packages_prefix "$version")"
    koopa::dl \
        'Packages' "$(koopa::to_string "$@")" \
        'Target' "$target"
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_flags=(
        "--target=${target}"
        '--disable-pip-version-check'
        '--no-warn-script-location'
        '--progress-bar=pretty'
        '--upgrade'
    )
    if [[ "$reinstall" -eq 1 ]]
    then
        pip_flags+=(
            '--force-reinstall'
            '--ignore-installed'
        )
    fi
    "$python" -m pip install "${install_flags[@]}" "$@"
    koopa::sys_set_permissions -r "$target"
    return 0
}

koopa::python_pip_outdated() { # {{{1
    # """
    # List oudated pip packages.
    # @note Updated 2021-06-14.
    #
    # Requesting 'freeze' format will return '<pkg>==<version>'.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_list/
    # """
    local prefix python version x
    python="$(koopa::locate_python)"
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
    # @note Updated 2021-06-14.
    # """
    local name name_fancy default_pkgs prefix pos python venv_python
    koopa::assert_has_no_envs
    name_fancy='Python virtual environment'
    python="$(koopa::locate_python)"
    pos=()
    while (("$#"))
    do
        case "$1" in
            --name=*)
                name="${1#*=}"
                shift 1
                ;;
            --python=*)
                python="${1#*=}"
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
    koopa::assert_is_set name python
    koopa::assert_is_installed "$python"
    prefix="$(koopa::python_venv_prefix)/${name}"
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
    koopa::sys_set_permissions -r "$prefix"
    "$venv_python" -m pip list
    koopa::install_success "$name_fancy" "$prefix"
    return 0
}

koopa::python_venv_create_base() { # {{{1
    # """
    # Create base Python virtual environment.
    # @note Updated 2021-06-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::python_venv_create --name='base'
    return 0
}

koopa::python_venv_create_r_reticulate() { # {{{1
    # """
    # Create Python virtual environment for reticulate in R.
    # @note Updated 2021-07-14.
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
    local cflags cppflags cxxflags dyld_library_path ldflags name packages
    koopa::assert_has_no_args "$#"
    name='r-reticulate'
    # FIXME Need to fetch the versions from our 'variables.txt' file instead.
    packages=(
        'Cython'
        'PyYAML'
        'louvain'
        'numpy'
        'pandas'
        'pip'
        'scikit-learn'
        'scipy'
        'setuptools'
        'umap-learn'
        'wheel'
    )
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
            'CXX' "${CXX:-}" \
            'CFLAGS' "${CFLAGS:-}" \
            'CPPFLAGS' "${CPPFLAGS:-}" \
            'CXXFLAGS' "${CXXFLAGS:-}" \
            'DYLD_LIBRARY_PATH' "${DYLD_LIBRARY_PATH:-}" \
            'LDFLAGS' "${LDFLAGS:-}"
    fi
    LLVM_CONFIG="$(koopa::locate_llvm_config)"
    koopa::assert_is_executable "$LLVM_CONFIG"
    export LLVM_CONFIG
    koopa::python_venv_create --name="$name" "${packages[@]}"
    return 0
}
