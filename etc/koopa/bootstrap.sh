#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2024-06-15.
# """

# Can debug with:
# > set -o xtrace

set -o errexit
set -o nounset

PREFIX="${PREFIX:-}"
if [ -z "$PREFIX" ]
then
    XDG_DATA_HOME="${XDG_DATA_HOME:-}"
    if [ -z "$XDG_DATA_HOME" ]
    then
        XDG_DATA_HOME="${HOME:?}/.local/share"
    fi
    PREFIX="${XDG_DATA_HOME}/koopa-bootstrap"
fi
PATH="${PREFIX}/bin:/usr/bin:/bin"
export PATH PREFIX

install_bash() {
    printf 'Installing bash.\n'
    mkdir -p "${PREFIX}/src/bash"
    cd "${PREFIX}/src/bash" || return 1
    curl \
        'https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'bash-5.2.21' || return 1
    ./configure --prefix="$PREFIX"
    make
    make install
    [ -x "${PREFIX}/bin/bash" ] || return 1
    return 0
}

install_coreutils() {
    printf 'Installing coreutils.\n'
    mkdir -p "${PREFIX}/src/coreutils"
    cd "${PREFIX}/src/coreutils" || return 1
    curl \
        'https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.gz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'coreutils-9.4' || return 1
    ./configure --prefix="$PREFIX" --program-prefix='g'
    make
    make install
    [ -x "${PREFIX}/bin/gcp" ] || return 1
    return 0
}

install_openssl3() {
    printf 'Installing openssl3.\n'
    mkdir -p "${PREFIX}/src/openssl3"
    cd "${PREFIX}/src/openssl3" || return 1
    curl \
        'https://www.openssl.org/source/openssl-3.3.1.tar.gz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'openssl-3.3.1' || return 1
    ./config \
        --libdir='lib' \
        --openssldir="$PREFIX" \
        --prefix="$PREFIX" \
        "-Wl,-rpath,${PREFIX}/lib" \
        'no-zlib' \
        'shared'
    make depend
    make
    make install_sw
    [ -x "${PREFIX}/bin/openssl" ] || return 1
    return 0
}

install_python() {
    printf 'Installing python.\n'
    mkdir -p "${PREFIX}/src/python"
    cd "${PREFIX}/src/python"
    curl \
        'https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'Python-3.11.9' || return 1
    ./configure \
        --prefix="$PREFIX" \
        --with-openssl="$PREFIX"
    make
    make install
    [ -x "${PREFIX}/bin/python3" ] || return 1
    return 0
}

main() {
    printf 'Installing koopa bootstrap in %s.\n' "$PREFIX"
    rm -fr "$PREFIX"
    mkdir -p "$PREFIX"
    (
        install_openssl3
        install_bash
        install_coreutils
        install_python
    )
    rm -fr "${PREFIX}/src"
    printf 'Bootstrap installation was successful.\n'
    return 0
}

main "$@"
