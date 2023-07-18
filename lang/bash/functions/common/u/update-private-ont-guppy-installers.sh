#!/usr/bin/env bash

koopa_update_private_ont_guppy_installers() {
    # """
    # Download and push Oxford Nanopore guppy installers to our private bucket.
    # @note Updated 2023-07-18.
    #
    # @seealso
    # - https://community.nanoporetech.com/downloads
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_has_private_access
    app['aws']="$(koopa_locate_aws)"
    koopa_assert_is_executable "${app[@]}"
    dict['base_url']='https://cdn.oxfordnanoportal.com/software/analysis'
    dict['name']='ont-guppy'
    dict['prefix']="$(koopa_tmp_dir)"
    dict['s3_profile']='acidgenomics'
    dict['s3_target']="$(koopa_private_installers_s3_uri)/${dict['name']}"
    dict['version']="$(koopa_app_json_version "${dict['name']}")"
    koopa_mkdir \
        "${dict['prefix']}/linux/amd64" \
        "${dict['prefix']}/linux/arm64" \
        "${dict['prefix']}/macos/amd64"
    koopa_download \
        "${dict['base_url']}/ont-guppy-cpu_${dict['version']}_linux64.tar.gz" \
        "${dict['prefix']}/linux/amd64/${dict['version']}-cpu.tar.gz"
    koopa_download \
        "${dict['base_url']}/ont-guppy_${dict['version']}_linux64.tar.gz" \
        "${dict['prefix']}/linux/amd64/${dict['version']}-gpu.tar.gz"
    koopa_download \
        "${dict['base_url']}/ont-guppy_${dict['version']}_linuxaarch64_\
cuda10.tar.gz" \
        "${dict['prefix']}/linux/arm64/${dict['version']}-gpu.tar.gz"
    koopa_download \
        "${dict['base_url']}/ont-guppy-cpu_${dict['version']}_osx64.zip" \
        "${dict['prefix']}/macos/amd64/${dict['version']}-cpu.zip"
    "${app['aws']}" s3 sync \
        --profile "${dict['s3_profile']}" \
        "${dict['prefix']}/" \
        "${dict['s3_target']}/"
    koopa_rm "${dict['prefix']}"
    return 0
}
