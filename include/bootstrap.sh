#!/usr/bin/env bash

set -Eeuo pipefail

cores=8

install_bash() {
    local file name tmp_dir url version
    name='bash'
    version='5.1'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="/tmp/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure
    make --jobs="$cores"
    sudo make install
    rm -fr "$tmp_dir"
    return 0
}

install_coreutils() {
    local file name tmp_dir url version
    name='coreutils'
    version='9.0'
    file="${name}-${version}.tar.gz"
    url="https://ftp.gnu.org/gnu/${name}/${file}" \
    tmp_dir="/tmp/${name}"
    mkdir -pv "$tmp_dir"
    cd "$tmp_dir" || return 1
    curl "$url" -o "$file"
    tar -xzvf "$file"
    cd "${name}-${version}"
    ./configure
    make --jobs="$cores"
    sudo make install
    rm -fr "$tmp_dir"
    return 0
}

main() {
    install_coreutils
    install_bash
}

main "$@"
