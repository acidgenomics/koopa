#!/usr/bin/env bash

koopa::install_bcl2fastq() { # {{{1
    # """
    # Install bcl2fastq.
    # @note Updated 2020-08-18.
    #
    # Using pre-built RPM package on Fedora / RHEL / CentOS.
    # Otherwise, build and install from source.
    # """
    local make_prefix name version version2
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
    # e.g. 2.20.0.422 to 2-20-0.
    version2="$(koopa::sub '\.[0-9]+$' '' "$version")"
    version2="$(koopa::kebab_case "$version2")"
    if koopa::is_fedora
    then
        prefix="$(koopa::app_prefix)"
    else
        prefix="$(koopa::cellar_prefix)"
    fi
    prefix="${prefix}/${name}/${version}"
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name" "$prefix"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        url_prefix="http://seq.cloud/install/bcl2fastq"
        if koopa::is_fedora
        then
            koopa::assert_is_installed rpm
            file="bcl2fastq2-v${version2}-linux-x86-64.zip"
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
        else
            file="bcl2fastq2-v${version2}-tar.zip"
            url="${url_prefix}/source/${file}"
            koopa::download "$url"
            koopa::extract "$file"
            koopa::extract "bcl2fastq2-v${version}-Source.tar.gz"
            koopa::cd bcl2fastq
            mkdir bcl2fastq-build
            koopa::cd bcl2fastq-build
            # Fix for missing '/usr/include/x86_64-linux-gnu/sys/stat.h'.
            export C_INCLUDE_PATH="/usr/include/x86_64-linux-gnu"
            ../src/configure --prefix="$prefix"
            jobs="$(koopa::cpu_count)"
            make --jobs="$jobs"
            make install
            # For some reason bcl2fastq creates an empty test directory.
            koopa::rm "${prefix}/bin/test"
            koopa::link_cellar "$name" "$version"
        fi
    )
    koopa::rm "$tmp_dir"
    koopa::install_success "$name" "$prefix"
    return 0
}
