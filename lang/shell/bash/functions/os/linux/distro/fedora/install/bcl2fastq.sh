#!/usr/bin/env bash

koopa:::fedora_install_bcl2fastq_from_rpm() { # {{{
    # """
    # Install bcl2fastq from Fedora/RHEL RPM file.
    # @note Updated 2021-05-06.
    # """
    local arch arch2 major_version name platform platform2 version version2
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed rpm
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    name='bcl2fastq'
    arch="$(koopa::arch)"
    arch2="$(koopa::kebab_case_simple "$arch")"
    platform='linux'
    platform2="$(koopa::capitalize "$platform")"
    major_version="$(koopa::major_version "$version")"
    # e.g. 2.20.0.422 to 2-20-0.
    version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
    version2="$(koopa::kebab_case_simple "$version2")"
    file="${name}${major_version}-v${version2}-${platform}-${arch2}.zip"
    url_prefix="http://seq.cloud/install/${name}"
    url="${url_prefix}/rpm/${file}"
    koopa::download "$url"
    koopa::extract "$file"
    sudo rpm -v \
        --force \
        --install \
        --prefix="${prefix}" \
        "${name}${major_version}-v${version}-${platform2}-${arch}.rpm"
    return 0
}
