#!/bin/sh

# """
# Bootstrap core dependencies.
# @note Updated 2022-11-28.
# """

set -o errexit
set -o nounset

PREFIX='/usr/local'
TMPDIR="$(mktemp -d)"

# Restrict the system path.
PATH='/usr/bin:/bin'
export PATH

# Deparallize, to ensure cross platform compatibility.
JOBS=1

install_bash() {
    local file name tmp_dir url version
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
    local file name tmp_dir url version
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

main() {
    [ -x "${PREFIX:?}/bin/bash" ] && return 0
    printf "Installing bootstrap into '%s'.\n" "${PREFIX:?}"
    # > rm -fr "${PREFIX:?}"
    # > install_coreutils
    install_bash
}

main "$@"
