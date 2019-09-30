#!/usr/bin/env bash

_koopa_assert_has_sudo



# Notes                                                                     {{{1
# ==============================================================================

# Use Spider Cache on Loads................................... : NO



# Variables                                                                 {{{1
# ==============================================================================

name="lmod"
version="$(_koopa_variable "$name")"
prefix="/opt/apps"
data_dir="/opt/moduleData"
tmp_dir="$(_koopa_tmp_dir)/${name}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install Lmod.

$(_koopa_help_args)

see also:
    https://lmod.readthedocs.io/

note:
    Bash script.
    Updated 2019-09-30.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

printf "Installing %s %s.\n" "$name" "$version"

# > _koopa_assert_is_not_dir "$prefix"

sudo mkdir -pv "$prefix"

(
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://github.com/TACC/Lmod/archive/${version}.tar.gz"
    tar xzvf "${version}.tar.gz"
    cd "Lmod-${version}" || exit 1
    ./configure \
        --prefix="${prefix}" \
        --with-spiderCacheDir="${data_dir}/cacheDir" \
        --with-updateSystemFn="${data_dir}/system.txt"
    sudo make install
    rm -fr "$tmp_dir"
)

module spider
