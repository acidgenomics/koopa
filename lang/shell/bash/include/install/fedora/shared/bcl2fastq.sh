#!/usr/bin/env bash

main() {
    # """
    # Install bcl2fastq binary from Fedora/RHEL RPM file.
    # @note Updated 2023-04-06.
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['aws']="$(koopa_locate_aws --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['installers_base']="$(koopa_private_installers_s3_uri)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['user']="$(koopa_user_name)"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['file']="${dict['version']}.zip"
    dict['url']="${dict['installers_base']}/${dict['name']}/fedora/\
${dict['arch']}/${dict['file']}"
    "${app['aws']}" --profile='acidgenomics' \
        s3 cp "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_fedora_install_from_rpm --prefix="${dict['prefix']}" ./*.rpm
    koopa_chown --recursive --sudo "${dict['user']}" "${dict['prefix']}"
    return 0
}
