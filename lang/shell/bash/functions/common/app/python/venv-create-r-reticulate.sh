#!/usr/bin/env bash

koopa::python_venv_create_r_reticulate() { # {{{1
    # """
    # Create Python virtual environment for reticulate in R.
    # @note Updated 2022-01-20.
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
        'numpy'
        'pandas'
        'scikit-learn'
        'scipy'
    )
    readarray -t pkgs <<< "$(koopa::python_get_pkg_versions "${pkgs[@]}")"
    if koopa::is_macos
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
        koopa::dl \
            'CC' "${CC:-}" \
            'CFLAGS' "${CFLAGS:-}" \
            'CPPFLAGS' "${CPPFLAGS:-}" \
            'CXX' "${CXX:-}" \
            'CXXFLAGS' "${CXXFLAGS:-}" \
            'DYLD_LIBRARY_PATH' "${DYLD_LIBRARY_PATH:-}" \
            'LDFLAGS' "${LDFLAGS:-}"
    fi
    koopa::python_venv_create --name='r-reticulate' "${pkgs[@]}" "$@"
    return 0
}
