#!/usr/bin/env bash

main() {
    # """
    # Install bcl2fastq binary from Fedora/RHEL RPM file.
    # @note Updated 2023-01-10.
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    # FIXME Need to add an assertion that user has koopa private access.
    declare -A app
    app['aws']="$(koopa_locate_aws)"
    [[ -x "${app['aws']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['installers_url']="$(koopa_private_installers_url)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['file']="${dict['version']}.zip"
# s3://private.koopa.acidgenomics.com/installers/bcl2fastq/fedora/amd64/2.20.zip
    dict['url']="${dict['installers_url']}/${dict['name']}/fedora/${dict['arch']}/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_fedora_install_from_rpm \
        --prefix="${dict['prefix']}" "${dict['file2']}"
    return 0
}
