#!/usr/bin/env bash
set -Eeuxo pipefail

# GnuPG
# https://www.gnupg.org/
#
# See also:
# - https://www.gnupg.org/download/
# - https://gist.github.com/simbo1905/ba3e8af9a45435db6093aea35c6150e8
# - https://github.com/gpg/gnupg/blob/master/INSTALL
# - https://www.dewinter.com/gnupg_howto/english/GPGMiniHowto-2.html

build_dir="/tmp/build/gnupg"
prefix="/usr/local"
gcrypt_url="https://www.gnupg.org/ftp/gcrypt"

echo "Installing GnuPG."

# Run preflight initialization checks.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=/dev/null
. "${script_dir}/_init.sh"

sudo yum-builddep -y gnupg2

# Download GnuPG release signing keys.
gpg --list-keys
gpg --keyserver hkp://keyserver.ubuntu.com:80 \
    --recv-keys 249B39D24F25E3B6 \
                04376F3EE0856959 \
                2071B08A33BD3F06 \
                8A861B1C7EFD60D9

mkdir -p "$build_dir"

(
    package="libgpg-error"
    version="1.31"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

(
    package="libgcrypt"
    version="1.8.4"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

(
    package="libassuan"
    version="2.5.3"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

(
    package="libksba"
    version="1.3.5"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

(
    package="npth"
    version="1.6"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    sudo make install
)

(
    package="pinentry"
    version="1.1.0"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix" --enable-pinentry-curses
    make
    sudo make install
)

# Update dynamic linker configuration.
sudo ldconfig -v

(
    package="gnupg"
    version="2.2.9"
    cd "$build_dir" || return 1
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2.sig"
    wget -c "${gcrypt_url}/${package}/${package}-${version}.tar.bz2"
    gpg --verify "${package}-${version}.tar.bz2.sig"
    tar -xjvf "${package}-${version}.tar.bz2"
    cd "${package}-${version}" || return 1
    ./configure --prefix="$prefix"
    make
    make check
    sudo make install
)

# Clean up the temp files.
rm -rf "$build_dir"

# Add local lib path to gpg configuration.
sudo sh -c 'echo /usr/local/lib > /etc/ld.so.conf.d/gpg2.conf'

# Update dynamic linker configuration.
sudo ldconfig -v

# Without the line below, gpg2 might fail to create / import secret keys.
# rm -rf ~/.gnugp

gpgconf --kill gpg-agent

echo "GnuPG installed successfully."
command -v gpg
gpg --version

