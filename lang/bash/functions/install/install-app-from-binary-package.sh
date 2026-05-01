#!/usr/bin/env bash

_koopa_install_app_from_binary_package() {
    # """
    # Install app from pre-built binary package.
    # @note Updated 2024-06-21.
    #
    # @examples
    # > _koopa_install_app_from_binary_package \
    # >     '/opt/koopa/app/aws-cli/2.7.7' \
    # >     '/opt/koopa/app/bash/5.1.16'
    # """
    local -A app dict
    local prefix
    _koopa_assert_has_args "$#"
    app['aws']="$(_koopa_locate_aws --allow-system)"
    app['tar']="$(_koopa_locate_tar --only-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch2)" # e.g. 'amd64'.
    dict['aws_profile']='acidgenomics'
    dict['binary_prefix']='/opt/koopa'
    dict['koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['os_string']="$(_koopa_os_string)"
    dict['s3_bucket']="s3://private.koopa.acidgenomics.com/binaries"
    dict['tmp_dir']="$(_koopa_tmp_dir)"
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        _koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    _koopa_assert_is_dir "$@"
    for prefix in "$@"
    do
        local -A dict2
        dict2['prefix']="$(_koopa_realpath "$prefix")"
        dict2['name']="$( \
            _koopa_print "${dict2['prefix']}" \
                | _koopa_dirname \
                | _koopa_basename \
        )"
        dict2['version']="$(_koopa_basename "$prefix")"
        dict2['tar_file']="${dict['tmp_dir']}/${dict2['name']}-\
${dict2['version']}.tar.gz"
        dict2['tar_url']="${dict['s3_bucket']}/${dict['os_string']}/\
${dict['arch']}/${dict2['name']}/${dict2['version']}.tar.gz"
        # Can quiet down with '--only-show-errors' here.
        "${app['aws']}" s3 cp \
            --profile "${dict['aws_profile']}" \
            "${dict2['tar_url']}" \
            "${dict2['tar_file']}"
        _koopa_assert_is_file "${dict2['tar_file']}"
        # Can increase verbosity with '-v' here.
        "${app['tar']}" -Pxz -f "${dict2['tar_file']}"
        _koopa_touch "${prefix}/.koopa-binary"
    done
    _koopa_rm "${dict['tmp_dir']}"
    return 0
}
