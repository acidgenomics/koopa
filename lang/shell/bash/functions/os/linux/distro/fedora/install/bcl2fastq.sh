#!/usr/bin/env bash

# FIXME Rethink this approach.
# FIXME Can we wrap in 'linux_install_app' call?
# Need to check in Docker image.

koopa:::fedora_install_bcl2fastq_from_rpm() { # {{{
    # """
    # Install bcl2fastq from Fedora/RHEL RPM file.
    # @note Updated 2020-01-20.
    #
    # This gets called inside 'koopa::linux_install_bcl2fastq'.
    # """
    local make_prefix name version version2
    koopa::assert_is_installed rpm
    version=
    while (("$#"))
    do
        case "$1" in
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    name='bcl2fastq'
    [[ -z "$version" ]] && version="$(koopa::variable "$name")"
    prefix="$(koopa::app_prefix)/${name}/${version}"
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        # e.g. 2.20.0.422 to 2-20-0.
        version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
        version2="$(koopa::kebab_case_simple "$version2")"
        file="bcl2fastq2-v${version2}-linux-x86-64.zip"
        url_prefix='http://seq.cloud/install/bcl2fastq'
        url="${url_prefix}/rpm/${file}"
        koopa::download "$url"
        koopa::extract "$file"
        sudo rpm -v \
            --force \
            --install \
            --prefix="${prefix}" \
            "bcl2fastq2-v${version}-Linux-x86_64.rpm"
        make_prefix="$(koopa::make_prefix)"
        koopa::sys_ln -t "${make_prefix}/bin" "${prefix}/bin/bcl2fastq"
    )
    koopa::rm "$tmp_dir"
    koopa::link_into_opt "$prefix" "$name"
    koopa::install_success "$name"
    return 0
}
