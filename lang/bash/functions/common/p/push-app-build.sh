#!/usr/bin/env bash

koopa_push_app_build() {
    # """
    # Create a tarball of app build, and push to S3 bucket.
    # @note Updated 2024-06-14.
    #
    # @examples
    # > koopa_push_app_build 'emacs' 'vim'
    #
    # @seealso
    # - aws s3 cp help
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     cli-configure-retries.html
    # - https://www.gnu.org/software/tar/manual/html_section/verbose.html
    # """
    local -A app dict
    local name
    koopa_assert_has_args "$#"
    koopa_can_push_binary || return 1
    app['aws']="$(koopa_locate_aws)"
    app['tar']="$(koopa_locate_tar --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(koopa_arch2)" # e.g. 'amd64'.
    dict['opt_prefix']="$(koopa_opt_prefix)"
    dict['os_string']="$(koopa_os_string)"
    dict['profile']='acidgenomics'
    dict['s3_bucket']='s3://private.koopa.acidgenomics.com/binaries'
    dict['tmp_dir']="$(koopa_tmp_dir)"
    # Attempt to avoid retry errors (default = 2) for CloudFront.
    # > export AWS_MAX_ATTEMPTS=5
    # > export AWS_RETRY_MODE='standard'
    for name in "$@"
    do
        local -A dict2
        dict2['name']="$name"
        dict2['prefix']="$( \
            koopa_realpath "${dict['opt_prefix']}/${dict2['name']}" \
        )"
        koopa_assert_is_dir "${dict2['prefix']}"
        if [[ -f "${dict2['prefix']}/.koopa-binary" ]]
        then
            koopa_alert_note "'${dict2['name']}' was installed as a binary."
            continue
        fi
        dict2['version']="$(koopa_basename "${dict2['prefix']}")"
        dict2['local_tar']="${dict['tmp_dir']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['s3_rel_path']="/${dict['os_string']}/${dict['arch']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['remote_tar']="${dict['s3_bucket']}${dict2['s3_rel_path']}"
        koopa_alert "Pushing '${dict2['prefix']}' to '${dict2['remote_tar']}'."
        koopa_mkdir "${dict['tmp_dir']}/${dict2['name']}"
        koopa_alert "Creating archive at '${dict2['local_tar']}'."
        # tar options:
        # * -P / --absolute-names (gtar)
        # * -P / --absolute-paths (bsdtar)
        # * -c / --create
        # * -g / --gzip
        # * -v / --verbose
        "${app['tar']}" \
            -Pcgvv \
            --totals \
            --file="${dict2['local_tar']}" \
            "${dict2['prefix']}/"
        koopa_alert "Copying to S3 at '${dict2['remote_tar']}'."
        "${app['aws']}" s3 cp \
            --profile "${dict['profile']}" \
            "${dict2['local_tar']}" "${dict2['remote_tar']}"
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
