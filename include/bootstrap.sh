#!/bin/sh
set -euo pipefail

# """
# Bootstrap core dependencies.
# @note Updated 2022-09-03.
# """

KOOPA_PREFIX="$(cd -- "$(dirname -- "$0")/.." && pwd)"
PREFIX="${KOOPA_PREFIX:?}/bootstrap"

PATH='/usr/bin:/bin'
export PATH

JOBS=8
TMPDIR="${TMPDIR:-/tmp}"

install_bash() {
    local file name tmp_dir url version
    name='bash'
    version='5.1'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="${TMPDIR}/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure --prefix="$PREFIX"
    make --jobs="$JOBS"
    make install
    rm -fr "$tmp_dir"
    return 0
}

install_coreutils() {
    local file name tmp_dir url version
    name='coreutils'
    version='9.1'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="${TMPDIR}/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure \
        --prefix="$PREFIX" \
        --program-prefix='g'
    make --jobs="$JOBS"
    make install
    rm -fr "$tmp_dir"
    return 0
}

main() {
    rm -fr "${PREFIX:?}"
    # > install_coreutils
    install_bash
}

main "$@"
