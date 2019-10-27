#!/usr/bin/env bash



# Notes                                                                     {{{1
# ==============================================================================

# Debian:
# > sudo apt install build-essential libreadline-dev

# Fedora:
# > install-lua

# > install-cellar-lua



# Variables                                                                 {{{1
# ==============================================================================

name="luarocks"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
exe_file="${prefix}/bin/${name}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install LuaRocks.

$(_koopa_help_args)

see also:
    - https://luarocks.org/
    - https://github.com/luarocks/luarocks/wiki/
          Installation-instructions-for-Unix

note:
    Bash script.
    Requires lua to be installed.
    Updated 2019-09-30.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

_koopa_message "Installing ${name} ${version}."

_koopa_assert_is_installed lua

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="${name}-${version}.tar.gz"
    wget "https://luarocks.org/releases/${file}"
    _koopa_extract "$file"
    cd "${name}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make build
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

# > build_prefix="$(_koopa_build_prefix)
# > export LUAROCKS_PREFIX="$build_prefix"

# Install Lmod dependencies.
luarocks install luaposix
luarocks install luafilesystem

_koopa_link_cellar "$name" "$version"

"$exe_file" --version
command -v "$exe_file"

lua -e 'print(package.path)'
