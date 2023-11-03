#!/usr/bin/env bash

koopa_install_app_from_binary_package() {
    # """
    # Install app from pre-built binary package.
    # @note Updated 2023-07-18.
    #
    # @examples
    # > koopa_install_app_from_binary_package \
    # >     '/opt/koopa/app/aws-cli/2.7.7' \
    # >     '/opt/koopa/app/bash/5.1.16'
    # """
    local -A app dict
    koopa_assert_has_args "$#"
    app['aws']="$(koopa_locate_aws --allow-system)"
    app['tar']="$(koopa_locate_tar --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['aws_profile']="${AWS_PROFILE:-acidgenomics}"
    dict['binary_prefix']='/opt/koopa'
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['os_string']="$(koopa_os_string)"
    dict['s3_bucket']="s3://private.koopa.acidgenomics.com/binaries"
    dict['tmp_dir']="$(koopa_tmp_dir)"
    if [[ "${dict['koopa_prefix']}" != "${dict['binary_prefix']}" ]]
    then
        koopa_stop "Binary package installation not supported for koopa \
install located at '${dict['koopa_prefix']}'. Koopa must be installed at \
default '${dict['binary_prefix']}' location."
    fi
    koopa_assert_is_dir "$@"
    (
        local prefix
        koopa_cd "${dict['tmp_dir']}"
        for prefix in "$@"
        do
            local -A dict2
            dict2['prefix']="$(koopa_realpath "$prefix")"
            dict2['name']="$( \
                koopa_print "${dict2['prefix']}" \
                    | koopa_dirname \
                    | koopa_basename \
            )"
            dict2['version']="$(koopa_basename "$prefix")"
            dict2['tar_file']="${dict['tmp_dir']}/\
${dict2['name']}-${dict2['version']}.tar.gz"
            dict2['tar_url']="${dict['s3_bucket']}/${dict['os_string']}/\
${dict['arch']}/${dict2['name']}/${dict2['version']}.tar.gz"
            "${app['aws']}" s3 cp \
                --only-show-errors \
                --profile "${dict['aws_profile']}" \
                "${dict2['tar_url']}" \
                "${dict2['tar_file']}"
            koopa_assert_is_file "${dict2['tar_file']}"
            "${app['tar']}" -Pxzf "${dict2['tar_file']}"
            koopa_touch "${prefix}/.koopa-binary"
        done
    )
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
