#!/usr/bin/env bash

koopa_fedora_add_google_cloud_sdk_repo() {
    # """
    # Add Google Cloud SDK repo.
    # @note Updated 2022-05-20.
    #
    # Spacing is important in the 'gpgkey' section.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#rpm
    #
    # Installation on Amazon Linux 2:
    # - https://github.com/kubernetes/kubernetes/issues/60134
    # - https://github.com/GoogleCloudPlatform/google-fluentd/issues/136
    # """
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app[sudo]}" ]] || return 1
    [[ -x "${app[tee]}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [enabled]=1
        [file]='/etc/yum.repos.d/google-cloud-sdk.repo'
        [gpgcheck]=1
        [repo_gpgcheck]=0
    )
    case "${dict[arch]}" in
        'x86_64')
            ;;
        *)
            koopa_stop 'Unsupported architecture.'
            ;;
    esac
    # NOTE May need to harden against unsupported RHEL 9 here.
    if koopa_is_fedora || koopa_is_rhel_8_like
    then
        dict[platform]='el8'
    elif koopa_is_rhel_7_like
    then
        dict[platform]='el7'
    else
        koopa_stop 'Unsupported platform.'
    fi
    dict[baseurl]="https://packages.cloud.google.com/yum/repos/\
cloud-sdk-${dict[platform]}-${dict[arch]}"
    [[ -f "${dict[file]}" ]] && return 0
    "${app[sudo]}" "${app[tee]}" "${dict[file]}" >/dev/null << END
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=${dict[baseurl]}
enabled=${dict[enabled]}
gpgcheck=${dict[gpgcheck]}
repo_gpgcheck=${dict[repo_gpgcheck]}
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
END
    return 0
}
