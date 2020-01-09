#!/usr/bin/env bash
set -Eeu -o pipefail

# Use autoconf instead of amalgamation.

# The '--enable-static' flag is required, otherwise you'll hit a version
# mismatch error.
#
# Example:
# > sqlite3 --version
# SQLite header and source version mismatch
# 2019-10-10 20:19:45 <hash>
# 2013-05-20 00:56:22 <hash>
#
# https://askubuntu.com/questions/443379

name="sqlite"
# e.g. 3300100
file_version="$(_koopa_variable "${name}-file-version")"
# e.g. 3.30.1
version="$(_koopa_variable "$name")"
year="$(_koopa_variable "${name}-year")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    rm -frv "$prefix"
    _koopa_cd_tmp_dir "$tmp_dir"
    file="sqlite-autoconf-${file_version}.tar.gz"
    url="https://www.sqlite.org/${year}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "sqlite-autoconf-${file_version}" || exit 1
    # --disable-dynamic-extensions
    # --disable-shared
    ./configure \
        --build="$build" \
        --enable-static \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
