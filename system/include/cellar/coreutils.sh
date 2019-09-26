#!/usr/bin/env bash

usage() {
cat << EOF
usage: install-cellar-coreutils [--help|-h]

Install GNU core utilities.

see also:
    - https://ftp.gnu.org/gnu/coreutils/

note:
    Bash script.
    Updated 2019-09-17.
EOF
}

_koopa_help "$@"

name="coreutils"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build_os_string="$(_koopa_build_os_string)"
exe_file="${prefix}/bin/env"

printf "Installing %s %s.\n" "$name" "$version"

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    wget "https://ftp.gnu.org/gnu/coreutils/coreutils-${version}.tar.xz"
    tar -xJvf "coreutils-${version}.tar.xz"
    cd "coreutils-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    # > make check
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

# Update '/usr/bin/env', if possible.
if _koopa_has_sudo
then
    link-coreutils-env
fi

"$exe_file" --version
command -v "$exe_file"
