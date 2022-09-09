#!/usr/bin/env bash

main() {
    # """
    # Install bcl2fastq binary from Fedora/RHEL RPM file.
    # @note Updated 2022-04-08.
    # """
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['installers_url']="$(koopa_koopa_installers_url)"
        ['name']='bcl2fastq'
        ['platform']='linux'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['arch2']="$(koopa_kebab_case_simple "${dict['arch']}")"
    dict['platform2']="$(koopa_capitalize "${dict['platform']}")"
    dict['maj_ver']="$(koopa_major_version "${dict['version']}")"
    # e.g. '2.20.0.422' to '2-20-0'.
    dict['version2']="$( \
        koopa_sub \
            --pattern='\.[0-9]+$' \
            --regex \
            --replacement='' \
            "${dict['version']}" \
    )"
    dict['version2']="$(koopa_kebab_case_simple "${dict['version2']}")"
    dict['file']="${dict['name']}${dict['maj_ver']}-v${dict['version2']}-\
${dict['platform']}-${dict['arch2']}.zip"
    url="${dict['installers_url']}/${dict['name']}/rpm/${dict['file']}"
    dict['file2']="${dict['name']}${dict['maj_ver']}-v${dict['version']}-\
${dict['platform2']}-${dict['arch']}.rpm"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_fedora_install_from_rpm --prefix="${dict['prefix']}" "${dict['file2']}"
    return 0
}
