#!/usr/bin/env bash

install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-04-28.
    #
    # ARM is not yet supported for this.
    # """
    local arch file major_version name prefix url version version2
    koopa::assert_is_linux
    name="${INSTALL_NAME:?}"
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    arch="$(koopa::arch)"
    major_version="$(koopa::major_version "$version")"
    # e.g. 2.20.0.422 to 2-20-0.
    version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
    version2="$(koopa::kebab_case_simple "$version2")"
    file="${name}${major_version}-v${version2}-tar.zip"
    url_prefix="http://seq.cloud/install/${name}"
    url="${url_prefix}/source/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::extract "${name}${major_version}-v${version}-Source.tar.gz"
    koopa::cd "$name"
    koopa::mkdir "${name}-build"
    koopa::cd "${name}-build"
    # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
    export C_INCLUDE_PATH="/usr/include/${arch}-linux-gnu"
    ../src/configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    # For some reason bcl2fastq creates an empty test directory.
    koopa::rm "${prefix}/bin/test"
    return 0
}

install_bcl2fastq "$@"
