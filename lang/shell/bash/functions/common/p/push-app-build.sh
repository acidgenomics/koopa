#!/usr/bin/env bash

# NOTE This also should invalidate cloud cache in a future update.

koopa_push_app_build() {
    # """
    # Create a tarball of app build, and push to S3 bucket.
    # @note Updated 2022-03-29.
    #
    # @examples
    # > koopa_push_app_build --app-name='node' --app-version='17.8.0'
    # # s3://koopa.acidgenomics.com/app/ubuntu-20/amd64/node/17.8.0.tar.gz
    # """
    local app dict pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [aws]="$(koopa_locate_aws)"
        [tar]="$(koopa_locate_tar)"
    )
    declare -A dict=(
        [app_name]=''
        [app_prefix]="$(koopa_app_prefix)"
        [app_version]=''
        [arch]="$(koopa_arch2)"
        [os_string]="$(koopa_os_string)"
        [s3_prefix]='s3://koopa.acidgenomics.com/app'
        [s3_profile]='acidgenomics'
        [tmp_dir]="$(koopa_tmp_dir)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--app-name='*)
                dict[app_name]="${1#*=}"
                shift 1
                ;;
            '--app-name')
                dict[app_name]="${2:?}"
                shift 2
                ;;
            '--app-version='*)
                dict[app_version]="${1#*=}"
                shift 1
                ;;
            '--app-version')
                dict[app_version]="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    if [[ "$#" -gt 0 ]]
    then
        koopa_assert_has_args_eq "$#" 2
        dict[app_name]="${1:?}"
        dict[app_version]="${2:?}"
    fi
    koopa_assert_is_set \
        '--app-name' "${dict[app_name]}" \
        '--app-version' "${dict[app_version]}"
    dict[prefix]="${dict[app_prefix]}/${dict[app_name]}/${dict[app_version]}"
    dict[local_tarball]="${dict[tmp_dir]}/${dict[app_version]}.tar.gz"
    dict[remote_tarball]="${dict[s3_prefix]}/${dict[os_string]}/${dict[arch]}/\
${dict[app_name]}/${dict[app_version]}.tar.gz"
    koopa_alert "Pushing '${dict[prefix]}' to '${dict[remote_tarball]}'."
    "${app[tar]}" -Pczf "${dict[local_tarball]}" "${dict[prefix]}/"
    "${app[aws]}" --profile="${dict[s3_profile]}" \
        s3 cp "${dict[local_tarball]}" "${dict[remote_tarball]}"
    koopa_rm "${dict[tmp_dir]}"
    return 0
}

