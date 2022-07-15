#!/usr/bin/env bash

koopa_push_app_build() {
    # """
    # Create a tarball of app build, and push to S3 bucket.
    # @note Updated 2022-07-15.
    #
    # @examples
    # > koopa_push_app_build 'emacs' 'vim'
    # """
    local app dict name
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [tar]="$(koopa_locate_tar)"
    )
    [[ -x "${app[aws]}" ]] || return 1
    [[ -x "${app[tar]}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch2)" # e.g. 'amd64'.
        [opt_prefix]="$(koopa_opt_prefix)"
        [os_string]="$(koopa_os_string)"
        [s3_prefix]='s3://koopa.acidgenomics.com/app'
        [s3_profile]='acidgenomics'
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    for name in "$@"
    do
        local dict2
        declare -A dict2
        dict2[name]="$name"
        dict2[prefix]="$(koopa_realpath "${dict[opt_prefix]}/${dict2[name]}")"
        dict2[version]="$(koopa_basename "${dict2[prefix]}")"
        dict2[local_tar]="${dict[tmp_dir]}/\
${dict2[name]}/${dict2[version]}.tar.gz"
        dict2[remote_tar]="${dict[s3_prefix]}/${dict[os_string]}/${dict[arch]}/\
${dict2[name]}/${dict2[version]}.tar.gz"
        koopa_alert "Pushing '${dict2[prefix]}' to '${dict2[remote_tar]}'."
        koopa_mkdir "${dict[tmp_dir]}/${dict2[name]}"
        "${app[tar]}" -Pczf "${dict2[local_tar]}" "${dict2[prefix]}/"
        "${app[aws]}" --profile="${dict[s3_profile]}" \
            s3 cp "${dict2[local_tar]}" "${dict2[remote_tar]}"
    done
    koopa_rm "${dict[tmp_dir]}"
    return 0
}
