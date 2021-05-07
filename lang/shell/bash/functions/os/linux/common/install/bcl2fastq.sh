#!/usr/bin/env bash

# NOTE Currently failing to install on Ubuntu 20.

koopa::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-05-06.
    #
    # Using pre-built RPM package on Fedora / RHEL / CentOS.
    # Otherwise, build and install from source.
    # """
    if koopa::is_fedora
    then
        koopa::install_app \
            --name='bcl2fastq' \
            --platform='fedora' \
            --installer='bcl2fastq-from-rpm' \
            "$@"
    else
        koopa::install_app \
            --name='bcl2fastq' \
            --platform='linux' \
            "$@"
    fi
    return 0
}

koopa:::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-05-07.
    #
    # This uses CMake to install.
    # ARM is not yet supported for this.
    # """
    local arch file jobs major_version name platform prefix url version version2
    koopa::activate_opt_prefix cmake
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='bcl2fastq'
    arch="$(koopa::arch)"
    platform='linux-gnu'
    jobs="$(koopa::cpu_count)"
    major_version="$(koopa::major_version "$version")"
    # e.g. 2.20.0.422 to 2-20-0.
    version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
    version2="$(koopa::kebab_case_simple "$version2")"
    file="${name}${major_version}-v${version2}-tar.zip"
    url="http://seq.cloud/install/${name}/source/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::extract "${name}${major_version}-v${version}-Source.tar.gz"
    koopa::cd "$name"
    koopa::mkdir "${name}-build"
    koopa::cd "${name}-build"
    # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
    export C_INCLUDE_PATH="/usr/include/${arch}-${platform}"
    ../src/configure --prefix="$prefix"
    make --jobs="$jobs"
    make install
    # For some reason bcl2fastq creates an empty test directory.
    koopa::rm "${prefix}/bin/test"
    return 0
}
