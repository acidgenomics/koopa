#!/usr/bin/env bash

koopa::install_julia() { # {{{1
    if koopa::is_linux
    then
        koopa::install_app \
            --name='julia' \
            --name-fancy='Julia' \
            --platform='linux' \
            --installer="julia-binary" \
            "$@"
    else
        koopa::install_app \
            --name='julia' \
            --name-fancy='Julia' \
            "$@"
    fi
}

koopa:::install_julia() { # {{{1
    # """
    # Install Julia (from source).
    # @note Updated 2021-05-04.
    # @seealso
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    # """
    local file jobs name prefix version url
    if koopa::is_macos
    then
        # NOTE Seeing this pop up on macOS:
        # # Warning: git information unavailable; versioning information limited
        # Including 'git' here makes no difference.
        koopa::activate_homebrew_opt_prefix gcc
    fi
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='julia'
    jobs="$(koopa::cpu_count)"
    # > file="v${version}.tar.gz"
    # > url="https://github.com/JuliaLang/julia/archive/${file}"
    file="${name}-${version}-full.tar.gz"
    url="https://github.com/JuliaLang/${name}/releases/download/\
v${version}/${file}"
    koopa::alert_coffee_time
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    # If set, this will interfere with internal LLVM build required for
    # Julia. See 'build.md' file for LLVM details.
    unset LLVM_CONFIG
    # Customize the 'Make.user' file.
    # Need to ensure we configure internal LLVM build here.
    cat > 'Make.user' << END
prefix=${prefix}
# > LLVM_ASSERTIONS=1
# > LLVM_DEBUG=Release
# > USE_BINARYBUILDER=0
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0
END
    make --jobs="$jobs"
    # > make test
    make install
    return 0
}
