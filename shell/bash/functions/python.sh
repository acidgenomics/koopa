#!/usr/bin/env bash

_koopa_venv_create() {
    # """
    # Create Python virtual environment.
    # @note Updated 2020-07-02.
    # """
    _koopa_assert_has_no_envs
    _koopa_assert_is_installed python3
    _koopa_assert_is_current_version python
    local name prefix py_exe
    name="${1:?}"
    prefix="$(_koopa_venv_prefix)/${name}"
    [[ -d "$prefix" ]] && return 0
    shift 1
    _koopa_info "Installing Python '${name}' virtual environment at '${prefix}'."
    _koopa_mkdir "$prefix"
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
    _koopa_set_permissions --recursive "$prefix"
    "$py_exe" -m pip list
    return 0
}

_koopa_venv_create_base() {
    # """
    # Create base Python virtual environment.
    # @note Updated 2020-07-03.
    # """
    _koopa_assert_has_no_args "$#"
    _koopa_venv_create "base"
    return 0
}

_koopa_venv_create_r_reticulate() {
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
    _koopa_assert_has_no_args "$#"
    local name packages
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
    if _koopa_is_macos
    then
        export CC="/usr/bin/clang"
        export CXX="/usr/bin/clang++"
        export CFLAGS="${CFLAGS:-} -I/usr/local/opt/libomp/include"
        export CPPFLAGS="${CPPFLAGS:-} -Xpreprocessor -fopenmp"
        export CXXFLAGS="${CXXFLAGS:-} -I/usr/local/opt/libomp/include"
        export DYLD_LIBRARY_PATH="/usr/local/opt/libomp/lib"
        export LDFLAGS="${LDFLAGS:-} -L/usr/local/opt/libomp/lib -lomp"
    fi
    if [[ -n "${LLVM_CONFIG:-}" ]]
    then
        _koopa_info "LLVM_CONFIG: '${LLVM_CONFIG}'."
    else
        _koopa_note "Export 'LLVM_CONFIG' to locate LLVM llvm-config binary."
    fi
    _koopa_venv_create "$name" "${packages[@]}"
    return 0
}
