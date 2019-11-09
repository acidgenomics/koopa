#!/usr/bin/env bash

_acid_assert_has_no_args "$@"

name="coreutils"
version="$(_acid_variable "$name")"
prefix="$(_acid_cellar_prefix)/${name}/${version}"
tmp_dir="$(_acid_tmp_dir)/${name}"
build_os_string="$(_acid_build_os_string)"
exe_file="${prefix}/bin/env"

_acid_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    rm -fr "$tmp_dir"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || exit 1
    file="coreutils-${version}.tar.xz"
    url="https://ftp.gnu.org/gnu/coreutils/${file}"
    _acid_download "$url"
    _acid_extract "$file"
    cd "coreutils-${version}" || exit 1
    ./configure \
        --build="$build_os_string" \
        --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    # > make check
    make install
    rm -fr "$tmp_dir"
)

_acid_link_cellar "$name" "$version"

# Update '/usr/bin/env', if possible.
if _acid_has_sudo
then
    link-coreutils-env
fi

"$exe_file" --version
command -v "$exe_file"
