#!/usr/bin/env bash
set -Eeu -o pipefail

# This is currently erroring out if LLVM 7 is installed.

# https://github.com/JuliaLang/julia/blob/master/doc/build/build.md
# https://github.com/JuliaLang/julia/blob/master/doc/build/linux.md
# https://docs.julialang.org/en/v1/devdocs/llvm/

name="julia"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="v${version}.tar.gz"
    url="https://github.com/JuliaLang/julia/archive/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "julia-${version}" || exit 1
    # Customize 'Make.user' file.
    # > echo "prefix=${prefix}" >> "Make.user"
    cat >"Make.user" <<EOL
prefix=${prefix}

# This doesn't work.
# LLVM_VER = 7.0.1

# This doesn't work either.
# LLVM_DEBUG = Release
# LLVM_ASSERTIONS = 1
EOL
    # This step is currently erroring out on RHEL 7 due to LLVM 7.
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
