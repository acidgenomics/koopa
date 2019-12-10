#!/usr/bin/env bash
set -Eeu -o pipefail

# See also:
# - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
# - https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
# - https://docs.julialang.org/en/v1/devdocs/llvm/
# - https://github.com/JuliaLang/julia/blob/master/doc/build/build.md#llvm
# - https://github.com/JuliaLang/julia/blob/master/Make.inc

# How to disable this?
# Warning: git information unavailable; versioning information limited

# Compile failure on Ubuntu 18:
# The program is attempting to use system LLVM 6, even when we request not to.
# > julia --version
# /usr/lib/x86_64-linux-gnu/libLLVM-6.0.so: version `JL_LLVM_6.0' not found
# (required by /usr/local/cellar/julia/1.3.0/bin/../lib/libjulia.so.1)

# https://discourse.julialang.org/t/problem-building-julia-version-jl-llvm-6-0-not-found/11545

# inside julia folder
# find . -name libLLVM-6.0.so
# gives
# ./usr/lib/libLLVM-6.0.so
# ./deps/scratch/llvm-6.0.0/build_Release/lib/libLLVM-6.0.so
# export LD_LIBRARY_PATH="$(pwd)/usr/lib/:$LD_LIBRARY_PATH"
# make

name="julia"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    # > file="v${version}.tar.gz"
    # > url="https://github.com/JuliaLang/julia/archive/${file}"
    file="julia-${version}-full.tar.gz"
    url="https://github.com/JuliaLang/julia/releases/download/v${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "julia-${version}" || exit 1
    # Customize the 'Make.user' file.
    # Need to ensure we configure internal LLVM build here.
    cat > Make.user << EOL
prefix=${prefix}
USE_LLVM_SHLIB=0
USE_SYSTEM_LLVM=0
# > LLVM_DEBUG=Release
# > LLVM_ASSERTIONS=1
EOL
    make --jobs="$jobs"
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
