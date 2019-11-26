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
    # This step is currently erroring out on RHEL 7 due to LLVM 7.
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
