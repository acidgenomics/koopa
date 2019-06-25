#!/usr/bin/env bash

# Install GnuPG.
# Modified 2019-06-25.

# See also:
# - https://www.gnupg.org/
# - https://www.gnupg.org/download/
# - https://gist.github.com/simbo1905/ba3e8af9a45435db6093aea35c6150e8
# - https://github.com/gpg/gnupg/blob/master/INSTALL
# - https://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-2.html

_koopa_assert_has_no_environments

name="gnupg"
version="$(koopa variable gpg)"
prefix="$(koopa cellar-prefix)/${name}/${version}"
tmp_dir="$(koopa tmp-dir)/${name}"
gcrypt_url="https://www.gnupg.org/ftp/gcrypt"
exe_file="${prefix}/bin/gpg"

printf "Installing GnuPG.\n"

# Download GnuPG release signing keys.
gpg --list-keys
gpg --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 249B39D24F25E3B6 \
                04376F3EE0856959 \
                2071B08A33BD3F06 \
                8A861B1C7EFD60D9

rm -rf "$tmp_dir"
mkdir -p "$tmp_dir"

(
    package="libgpg-error"
    version="$(koopa variable "$package")"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make
    make install
)

link-cellar "$name" "$version"

(
    package="libgcrypt"
    version="$(koopa variable "$package")"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make
    make install
)

link-cellar "$name" "$version"

(
    package="libassuan"
    version="$(koopa variable "$package")"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make
    make install
)

link-cellar "$name" "$version"

(
    package="libksba"
    version="$(koopa variable "$package")"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make
    make install
)

link-cellar "$name" "$version"

(
    package="npth"
    version="$(koopa variable "$package")"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make
    make install
)

link-cellar "$name" "$version"

(
    package="pinentry"
    version="$(koopa variable "$package")"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix" --enable-pinentry-curses
    make
    make install
)

link-cellar "$name" "$version"

(
    package="gnupg"
    version="$(koopa variable gpg)"
    cd "$tmp_dir" || exit 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || exit 1
    ./configure --prefix="$prefix"
    make
    make check
    make install
)

link-cellar "$name" "$version"

rm -rf "$tmp_dir"

# Without the line below, gpg2 might fail to create / import secret keys.
# > rm -rf ~/.gnugp

gpgconf --kill gpg-agent

command -v "$exe_file"
"$exe_file" --version
