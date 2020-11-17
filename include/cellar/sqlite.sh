#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Use autoconf instead of amalgamation.
#
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
# """

case "$version" in
    3.33.*)
        year='2020'
        ;;
    3.32.*)
        year='2020'
        ;;
    *)
        koopa::stop 'Unsupported version.'
        ;;
esac
# e.g. 3.32.3 to 3320300.
file_version="$( \
    koopa::print "$version" \
    | sed -E 's/^([0-9]+)\.([0-9]+)\.([0-9]+)$/\1\20\300/'
)"
file="${name}-autoconf-${file_version}.tar.gz"
url="https://www.sqlite.org/${year}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-autoconf-${file_version}"
flags=(
    # Potential flags:
    # > '--disable-dynamic-extensions'
    # > '--disable-shared'
    "--prefix=${prefix}"
    '--enable-static'
)
./configure "${flags[@]}"
make --jobs="$jobs"
make install
