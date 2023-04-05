#!/usr/bin/env bash

koopa_push_app_build() {
    # """
    # Create a tarball of app build, and push to S3 bucket.
    # @note Updated 2023-01-01.
    #
    # @examples
    # > koopa_push_app_build 'emacs' 'vim'
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     cli-configure-retries.html
    # - https://www.gnu.org/software/tar/manual/html_section/verbose.html
    # """
    local app dict name
    koopa_assert_has_args "$#"
    koopa_can_install_binary || return 1
    local -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['tar']="$(koopa_locate_tar)"
    )
    [[ -x "${app['aws']}" ]] || exit 1
    [[ -x "${app['tar']}" ]] || exit 1
    local -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['os_string']="$(koopa_os_string)"
        ['profile']='acidgenomics'
        ['s3_bucket']='s3://private.koopa.acidgenomics.com/binaries'
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
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
        "${app['tar']}" \
            --absolute-names \
            --create \
            --gzip \
            --totals \
            --verbose \
            --verbose \
            --file="${dict2['local_tar']}" \
            "${dict2['prefix']}/"
        koopa_alert "Copying to S3 at '${dict2['remote_tar']}'."
        "${app['aws']}" --profile="${dict['profile']}" \
            s3 cp "${dict2['local_tar']}" "${dict2['remote_tar']}"
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
