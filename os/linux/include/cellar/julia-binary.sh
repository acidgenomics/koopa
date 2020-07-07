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
# > julia --version
# /usr/lib/x86_64-linux-gnu/libLLVM-6.0.so: version `JL_LLVM_6.0' not found
# (required by /usr/local/cellar/julia/1.3.0/bin/../lib/libjulia.so.1)
#
# See also:
# https://discourse.julialang.org/t/
#     problem-building-julia-version-jl-llvm-6-0-not-found/11545
# """

minor_version="$(koopa::major_minor_version "$version")"
file="${name}-${version}-linux-x86_64.tar.gz"
url="https://julialang-s3.julialang.org/bin/linux/x64/${minor_version}/${file}"
koopa::download "$url"
koopa::extract "$file"
cd "${name}-${version}" || exit 1
rm LICENSE.md
koopa::mkdir "$prefix"
cp -r . "$prefix"
