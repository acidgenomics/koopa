#!/usr/bin/env bash

koopa::pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2021-05-02.
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # """
    local install_flags pos python reinstall target
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
    koopa::is_installed "$python" || return 0
    # FIXME Need to rework the version handling here...
    koopa::python_add_site_packages_to_sys_path "$python"
    # FIXME Need to pass the version here instead...
    target="$(koopa::python_packages_prefix "$python")"  # FIXME
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
    return 0
}

koopa::pip_outdated() { # {{{1
    # """
    # List oudated pip packages.
    # @note Updated 2021-05-04.
    #
    # Requesting 'freeze' format will return '<pkg>==<version>'.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_list/
    # """
    local prefix python x
    python="$(koopa::python)"
    prefix="$(koopa::python_packages_prefix)"  # FIXME
    x="$( \
        "$python" -m pip list \
            --format 'freeze' \
            --outdated \
            --path "$prefix" \
    )"
    koopa::print "$x"
    return 0
}

koopa::pyscript() { # {{{1
    # """
    # Execute a Python script.
    # @note Updated 2020-11-19.
    # """
    local name prefix python script
    koopa::assert_has_args "$#"
    python="$(koopa::python)"
    prefix="$(koopa::pyscript_prefix)"
    name="${1:?}"
    shift 1
    script="${prefix}/${name}.py"
    koopa::assert_is_file "$script"
    "$python" "$script" "$@"
    return 0
}

koopa::python_add_site_packages_to_sys_path() { # {{{1
    # """
    # Add our custom site packages library to sys.path.
    # @note Updated 2021-05-19.
    #
    # @seealso
    # > "$python" -m site
    # """
    local file k_site_pkgs major_minor_version python sys_site_pkgs version
    python="${1:-}"
    [[ -z "$python" ]] && python="$(koopa::python)"
    version="$(koopa::get_version "$python")"
    major_minor_version="$(koopa::major_minor_version "$version")"
    sys_site_pkgs="$(koopa::python_system_packages_prefix "$python")"
    k_site_pkgs="$(koopa::python_packages_prefix "$major_minor_version")"
    [[ ! -d "${k_site_pkgs:?}" ]] && koopa::sys_mkdir "$k_site_pkgs"
    file="${sys_site_pkgs:?}/koopa.pth"
    koopa::alert "Adding '${file}' path file in '${sys_site_pkgs}'."
    if koopa::is_symlinked_app "$python"
    then
        koopa::write_string "$k_site_pkgs" "$file"
        koopa::link_app python
    else
        koopa::sudo_write_string "$k_site_pkgs" "$file"
    fi
    "$python" -m site
    return 0
}

koopa::python_remove_pycache() { # {{{1
    # """
    # Remove Python '__pycache__/' from site packages.
    # @note Updated 2020-08-13.
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
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    python="$(koopa::which_realpath "$python")"
    prefix="$(koopa::parent_dir -n 2 "$python")"
    koopa::alert "Removing pycache in '${prefix}'."
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
    # @note Updated 2021-01-14.
    # """
    local name name_fancy default_pkgs prefix pos python venv_python
    koopa::assert_has_no_envs
    name_fancy='Python virtual environment'
    python="$(koopa::python)"
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
    prefix="$(koopa::venv_prefix)/${name}"
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

koopa::venv_create_base() { # {{{1
    # """
    # Create base Python virtual environment.
    # @note Updated 2021-01-14.
    # """
    koopa::assert_has_no_args "$#"
    koopa::venv_create --name='base'
    return 0
}

koopa::venv_create_r_reticulate() { # {{{1
    # """
    # Create Python virtual environment for reticulate in R.
    # @note Updated 2021-01-14.
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
        koopa::stop 'Export "LLVM_CONFIG" to locate LLVM llvm-config binary.'
    fi
    koopa::venv_create --name="$name" "${packages[@]}"
    return 0
}
