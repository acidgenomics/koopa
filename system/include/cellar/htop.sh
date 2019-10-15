#!/usr/bin/env bash



# Notes                                                                     {{{1
# ==============================================================================

# error while loading shared libraries: libncursesw.so.6
#
# Current configuration on RHEL 7 has libncursesw.so.5
#
# ldd ./htop
# ldconfig -p | grep libncurses
# ldconfig -p | grep libtinfow



# Variables                                                                 {{{1
# ==============================================================================

name="htop"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"



# Usage                                                                     {{{1
# ==============================================================================

usage() {
cat << EOF
$(_koopa_help_header "install-cellar-${name}")

Install htop.

$(_koopa_help_args)

see also:
    - https://hisham.hm/htop/releases/
    - https://github.com/hishamhm/htop

note:
    Bash script.
    Requires Python to be installed.
    Updated 2019-10-15.
EOF
}

_koopa_help "$@"



# Script                                                                    {{{1
# ==============================================================================

printf "Installing %s %s.\n" "$name" "$version"

_koopa_assert_is_installed python

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://hisham.hm/htop/releases/${version}/htop-${version}.tar.gz"
    tar -xzvf "htop-${version}.tar.gz"
    cd "htop-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --disable-unicode \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

command -v "$exe_file"
"$exe_file" --version
