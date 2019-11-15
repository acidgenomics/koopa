#!/usr/bin/env bash
set -Eeu -o pipefail

name="gnupg"
version="$(_koopa_variable gpg)"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
gcrypt_url="https://www.gnupg.org/ftp/gcrypt"
exe_file="${prefix}/bin/gpg"

_koopa_message "Installing ${name} ${version}."

# Download GnuPG release signing keys.
if _koopa_is_installed gpg
then
    gpg --list-keys
    gpg --keyserver hkp://keyserver.ubuntu.com:80 \
        --recv-keys 249B39D24F25E3B6 \
                    04376F3EE0856959 \
                    2071B08A33BD3F06 \
                    8A861B1C7EFD60D9
fi

rm -fr "$tmp_dir"
mkdir -pv "$tmp_dir"

(
    pkg="libgpg-error"
    ver="$(_koopa_variable "$pkg")"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

(
    pkg="libgcrypt"
    ver="$(_koopa_variable "$pkg")"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

(
    pkg="libassuan"
    ver="$(_koopa_variable "$pkg")"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

(
    pkg="libksba"
    ver="$(_koopa_variable "$pkg")"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

(
    pkg="npth"
    ver="$(_koopa_variable "$pkg")"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

(
    pkg="pinentry"
    ver="$(_koopa_variable "$pkg")"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix" --enable-pinentry-curses
    make --jobs="$CPU_COUNT"
    make install
)

_koopa_link_cellar "$name" "$version"

(
    pkg="gnupg"
    ver="$(_koopa_variable gpg)"
    cd "$tmp_dir" || exit 1
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2.sig"
    _koopa_download "${gcrypt_url}/${pkg}/${pkg}-${ver}.tar.bz2"
    if _koopa_is_installed gpg
    then
        gpg --verify "${pkg}-${ver}.tar.bz2.sig"
    fi
    _koopa_extract "${pkg}-${ver}.tar.bz2"
    cd "${pkg}-${ver}" || exit 1
    ./configure --prefix="$prefix"
    make --jobs="$CPU_COUNT"
    make check
    make install
)

_koopa_link_cellar "$name" "$version"

rm -rf "$tmp_dir"

# Without the line below, gpg2 might fail to create / import secret keys.
# > rm -rf ~/.gnugp

gpgconf --kill gpg-agent

command -v "$exe_file"
"$exe_file" --version
