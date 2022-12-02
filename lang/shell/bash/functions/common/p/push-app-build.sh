#!/usr/bin/env bash

koopa_push_app_build() {
    # """
    # Create a tarball of app build, and push to S3 bucket.
    # @note Updated 2022-10-18.
    #
    # @examples
    # > koopa_push_app_build 'emacs' 'vim'
    #
    # @seealso
    # - https://docs.aws.amazon.com/cli/latest/userguide/
    #     cli-configure-retries.html
    # """
    local app dict name
    koopa_assert_has_args "$#"
    koopa_can_install_binary || return 1
    declare -A app=(
        ['aws']="$(koopa_locate_aws)"
        ['tar']="$(koopa_locate_tar --allow-system)"
    )
    [[ -x "${app['aws']}" ]] || return 1
    [[ -x "${app['tar']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch2)" # e.g. 'amd64'.
        ['opt_prefix']="$(koopa_opt_prefix)"
        ['os_string']="$(koopa_os_string)"
        ['profile']='acidgenomics'
        ['s3_bucket']='s3://app.koopa.acidgenomics.com'
        ['tmp_dir']="$(koopa_tmp_dir)"
    )
    # Attempt to avoid retry errors (default = 2) for CloudFront.
    # > export AWS_MAX_ATTEMPTS=5
    # > export AWS_RETRY_MODE='standard'
    for name in "$@"
    do
        local dict2
        declare -A dict2
        dict2['name']="$name"
        dict2['prefix']="$( \
            koopa_realpath "${dict['opt_prefix']}/${dict2['name']}" \
        )"
        koopa_assert_is_dir "${dict2['prefix']}"
        dict2['version']="$(koopa_basename "${dict2['prefix']}")"
        dict2['local_tar']="${dict['tmp_dir']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['s3_rel_path']="/${dict['os_string']}/${dict['arch']}/\
${dict2['name']}/${dict2['version']}.tar.gz"
        dict2['remote_tar']="${dict['s3_bucket']}${dict2['s3_rel_path']}"
        koopa_alert "Pushing '${dict2['prefix']}' to '${dict2['remote_tar']}'."
        koopa_mkdir "${dict['tmp_dir']}/${dict2['name']}"
        # FIXME GNU tar supports '--totals', which may be useful for progress.
        # https://www.gnu.org/software/tar/manual/html_section/verbose.html
        "${app['tar']}" -Pczf "${dict2['local_tar']}" "${dict2['prefix']}/"
        "${app['aws']}" --profile="${dict['profile']}" \
            s3 cp "${dict2['local_tar']}" "${dict2['remote_tar']}"
    done
    koopa_rm "${dict['tmp_dir']}"
    return 0
}
