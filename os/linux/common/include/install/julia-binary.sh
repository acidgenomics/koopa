#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
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
# The program is attempting to use system LLVM 6, even when we request not to.
#
# See also:
# https://discourse.julialang.org/t/
#     problem-building-julia-version-jl-llvm-6-0-not-found/11545
# """

koopa::assert_is_linux
minor_version="$(koopa::major_minor_version "$version")"
arch="$(koopa::arch)"
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
