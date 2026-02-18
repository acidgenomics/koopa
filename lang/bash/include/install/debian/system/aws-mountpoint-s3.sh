#!/usr/bin/env bash

main() {
    # """
    # Install AWS Mountpoint for S3.
    # @note Updated 2026-02-18.
    #
    # @seealso
    # - https://github.com/awslabs/mountpoint-s3
    # - https://aws.amazon.com/s3/features/mountpoint/
    # - https://docs.aws.amazon.com/AmazonS3/latest/userguide/
    #   mountpoint-installation.html
    # """
    local -A dict
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    if koopa_is_arm64
    then
        dict['arch']='arm64'
    elif koopa_is_amd64
    then
        dict['arch']='x86_64'
    fi
    dict['url']="https://s3.amazonaws.com/mountpoint-s3-release/\
${dict['version']}/${dict['arch']}/mount-s3-${dict['version']}-\
${dict['arch']}.deb"
    dict['file']="$(koopa_basename "${dict['url']}")"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_debian_install_from_deb "${dict['file']}"
    koopa_rm "${dict['file']}"
    return 0
}
