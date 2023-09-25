#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2023-09-25.
# """

set -o errexit
set -o nounset
set -o xtrace

PATH='/usr/bin:/bin'
TMPDIR="$(mktemp -d)"
PREFIX="${TMPDIR}/bootstrap"
export PATH PREFIX TMPDIR

install_bash() {
    mkdir -p "${TMPDIR}/src/bash"
    cd "${TMPDIR}/src/bash" || return 1
    curl \
        'https://ftp.gnu.org/gnu/bash/bash-5.2.15.tar.gz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'bash-5.2.15' || return 1
    ./configure --prefix="$PREFIX"
    make
    make install
    return 0
}

install_coreutils() {
    mkdir -p "${TMPDIR}/src/coreutils"
    cd "${TMPDIR}/src/coreutils" || return 1
    curl \
        'https://ftp.gnu.org/gnu/coreutils/coreutils-9.4.tar.gz' \
        -o 'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'coreutils-9.4' || return 1
    ./configure --prefix="${PREFIX:?}" --program-prefix='g'
    make
    make install
    return 0
}

install_python() {
    mkdir -p "${TMPDIR}/src/python"
    cd "${TMPDIR}/src/python"
    curl \
        'https://www.python.org/ftp/python/3.11.5/Python-3.11.5.tgz' \
        'src.tar.gz'
    tar -xzf 'src.tar.gz'
    cd 'Python-3.11.5' || return 1
    ./configure --prefix="$PREFIX"
    make
    make install
    return 0
}

main() {
    printf "Installing bootstrap into '%s'.\n" "$PREFIX"
    (
        install_bash
        install_coreutils
        install_python
    )
    [ -x "${PREFIX}/bin/bash" ] || return 1
    [ -x "${PREFIX}/bin/gcp" ] || return 1
    [ -x "${PREFIX}/bin/python3" ] || return 1
    printf '%s\n' "$PREFIX"
    return 0
}

main "$@"
