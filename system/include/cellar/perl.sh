#!/usr/bin/env bash
set -Eeu -o pipefail

# https://www.cpan.org/src/
# https://metacpan.org/pod/distribution/perl/INSTALL
# https://perlmaven.com/how-to-build-perl-from-source-code

name="perl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="perl-${version}.tar.gz"
    url="https://www.cpan.org/src/5.0/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "perl-${version}" || exit 1
    ./Configure \
        -des \
        -Dprefix="$prefix"
    make --jobs="$jobs"
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

_koopa_message "Installing CPAN Minus."
"${prefix}/bin/cpan" App::cpanminus
_koopa_link_cellar "$name" "$version"

_koopa_message "Installing 'File::Rename' module."
"${prefix}/bin/cpanm" File::Rename
_koopa_link_cellar "$name" "$version"
