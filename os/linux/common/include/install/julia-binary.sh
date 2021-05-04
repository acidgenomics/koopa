#!/usr/bin/env bash

install_julia_binary() { # {{{1
    # """
    # Install Julia from binary.
    # @note Updated 2021-04-28.
    #
    # Install the generic binaries by default, when possible.
    # https://julialang.org/downloads/
    #
    # Build from source instructions:
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
    # - https://docs.julialang.org/en/v1/devdocs/llvm/
    # - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
    # - https://github.com/JuliaLang/julia/blob/master/Make.inc
    #
    # Source compile failure on Ubuntu 18 LTS.
    # The program is attempting to use system LLVM 6.
    #
    # See also:
    # https://discourse.julialang.org/t/
    #     problem-building-julia-version-jl-llvm-6-0-not-found/11545
    # """
    local arch file minor_version name prefix subdir url version
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='julia'
    arch="$(koopa::arch)"
    minor_version="$(koopa::major_minor_version "$version")"
    file="${name}-${version}-linux-${arch}.tar.gz"
    case "$arch" in
        x86*)
            subdir='x86'
            ;;
        *)
            subdir="$arch"
            ;;
    esac
    url="https://julialang-s3.julialang.org/bin/linux/${subdir}/\
${minor_version}/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::cd "${name}-${version}"
    koopa::rm 'LICENSE.md'
    koopa::mkdir "$prefix"
    koopa::cp . "$prefix"
    return 0
}

install_julia_binary "$@"
