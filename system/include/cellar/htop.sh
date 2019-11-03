#!/usr/bin/env bash

_koopa_help "$@"
_koopa_assert_has_no_args "$@"
_koopa_assert_is_installed python



# Notes                                                                     {{{1
# ==============================================================================

# htop may fail to compile/load due to libncurses.
# We can fix this by disabling Unicode support in the build.
#
# error while loading shared libraries: libncursesw.so.6
#
# Current configuration on RHEL 7 has libncursesw.so.5
#
# ldconfig -p | grep libncurses
# ldconfig -p | grep libtinfow
# ldd ./htop
#
# See also:
# - https://github.com/hishamhm/htop/issues/858



# Variables                                                                 {{{1
# ==============================================================================

name="htop"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/${name}"



# Script                                                                    {{{1
# ==============================================================================

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://hisham.hm/htop/releases/${version}/htop-${version}.tar.gz"
    _koopa_extract "htop-${version}.tar.gz"
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
