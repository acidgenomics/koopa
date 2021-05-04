#!/usr/bin/env bash

koopa::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-02-15.
    #
    # Using pre-built RPM package on Fedora / RHEL / CentOS.
    # Otherwise, build and install from source.
    # """
    if koopa::is_fedora
    then
        koopa:::fedora_install_bcl2fastq_from_rpm "$@"
    else
        koopa::linux_install_app --name='bcl2fastq' "$@"
    fi
    return 0
}

koopa:::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-04-29.
    #
    # ARM is not yet supported for this.
    # """
    local arch file jobs major_version prefix url version version2
    koopa::assert_is_linux
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    arch="$(koopa::arch)"
    jobs="$(koopa::cpu_count)"
    major_version="$(koopa::major_version "$version")"
    # e.g. 2.20.0.422 to 2-20-0.
    version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
    version2="$(koopa::kebab_case_simple "$version2")"
    file="bcl2fastq${major_version}-v${version2}-tar.zip"
    url_prefix="http://seq.cloud/install/bcl2fastq"
    url="${url_prefix}/source/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::extract "bcl2fastq${major_version}-v${version}-Source.tar.gz"
    koopa::cd 'bcl2fastq'
    koopa::mkdir 'bcl2fastq-build'
    koopa::cd 'bcl2fastq-build'
    # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
    export C_INCLUDE_PATH="/usr/include/${arch}-linux-gnu"
    ../src/configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    # For some reason bcl2fastq creates an empty test directory.
    koopa::rm "${prefix}/bin/test"
    return 0
}
