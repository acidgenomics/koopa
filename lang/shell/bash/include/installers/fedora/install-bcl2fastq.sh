#!/usr/bin/env bash

koopa:::fedora_install_bcl2fastq_from_rpm() { # {{{
    # """
    # Install bcl2fastq from Fedora/RHEL RPM file.
    # @note Updated 2022-01-07.
    # """
    local dict
    koopa::assert_has_no_args "$#"
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [installers_url]="$(koopa::koopa_installers_url)"
        [name]='bcl2fastq'
        [platform]='linux'
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    dict[arch2]="$(koopa::kebab_case_simple "${dict[arch]}")"
    dict[platform2]="$(koopa::capitalize "${dict[platform]}")"
    dict[maj_ver]="$(koopa::major_version "${dict[version]}")"
    # e.g. '2.20.0.422' to '2-20-0'.
    dict[version2]="$(koopa::sub '\.[0-9]+$' '' "${dict[version]}")"
    dict[version2]="$(koopa::kebab_case_simple "${dict[version2]}")"
    dict[file]="${dict[name]}${dict[maj_ver]}-v${dict[version2]}-\
${dict[platform]}-${dict[arch2]}.zip"
    url="${dict[installers_url]}/${dict[name]}/rpm/${dict[file]}"
    dict[file2]="${dict[name]}${dict[maj_ver]}-v${dict[version]}-\
${dict[platform2]}-${dict[arch]}.rpm"
    koopa::download "${dict[url]}" "${dict[file]}"
    koopa::extract "${dict[file]}"
    koopa::fedora_install_from_rpm --prefix="${dict[prefix]}" "${dict[file2]}"
    return 0
}
