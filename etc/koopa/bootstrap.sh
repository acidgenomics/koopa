#!/bin/sh

# FIXME Install to temporary directory.
# FIXME Install Python here.
# FIXME Return the temporary directory path at end of function.

# """
# Bootstrap core dependencies.
# @note Updated 2023-09-23.
# """

set -o errexit
set -o nounset

JOBS=1
PATH='/usr/bin:/bin'
TMPDIR="$(mktemp -d)"
PREFIX="${TMPDIR}/bootstrap"
export JOBS PATH PREFIX TMPDIR

install_bash() {
    name='bash'
    version='5.2'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="${TMPDIR:?}/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure --prefix="${PREFIX:?}"
    make --jobs="${JOBS:?}"
    sudo make install
    rm -fr "$tmp_dir"
    return 0
}

install_coreutils() {
    name='coreutils'
    version='9.1'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="${TMPDIR:?}/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure \
        --prefix="${PREFIX:?}" \
        --program-prefix='g'
    make --jobs="${JOBS:?}"
    sudo make install
    rm -fr "$tmp_dir"
    return 0
}

# FIXME Add support for Python
# install_python

main() {
    if [ -x "${PREFIX:?}/bin/bash" ]
    then
        printf "Bash is already installed at '%s'.\n" "${PREFIX:?}"
        return 0
    fi
    printf "Installing bootstrap into '%s'.\n" "${PREFIX:?}"
    # > rm -fr "${PREFIX:?}"
    # > install_coreutils
    install_bash
}

main "$@"
