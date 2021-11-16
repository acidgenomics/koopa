#!/usr/bin/env bash

# NOTE Currently failing to install on Ubuntu 20.
# ## include could not find load file:
# ## CMakeFindDependencyMacro
# ## Unknown CMake command "find_dependency".

# FIXME Need to rework using app and dict approach.
koopa:::linux_install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2021-06-16.
    #
    # This uses CMake to install.
    # ARM is not yet supported for this.
    # """
    local arch file jobs major_version make name platform prefix
    local url version version2
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    arch="$(koopa::arch)"
    jobs="$(koopa::cpu_count)"
    make="$(koopa::locate_make)"
    name='bcl2fastq'
    platform='linux-gnu'
    major_version="$(koopa::major_version "$version")"
    # e.g. 2.20.0.422 to 2-20-0.
    version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
    version2="$(koopa::kebab_case_simple "$version2")"
    file="${name}${major_version}-v${version2}-tar.zip"
    url="https://seq.cloud/install/${name}/source/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    koopa::extract "${name}${major_version}-v${version}-Source.tar.gz"
    (
        koopa::cd "$name"
        koopa::mkdir "${name}-build"
    )
    (
        koopa::cd "${name}-build"
        # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
        export C_INCLUDE_PATH="/usr/include/${arch}-${platform}"
        ../src/configure --prefix="$prefix"
        "$make" --jobs="$jobs"
        "$make" install
    )
    # For some reason bcl2fastq creates an empty test directory.
    koopa::rm "${prefix}/bin/test"
    return 0
}
