#!/usr/bin/env bash

koopa::fedora_add_azure_cli_repo() { # {{{1
    # """
    # Add Microsoft Azure CLI repo.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [file]='/etc/yum.repos.d/azure-cli.repo'
    )
    [[ -f "${dict[file]}" ]] && return 0
    "${app[sudo]}" "${app[tee]}" "${dict[file]}" >/dev/null << END
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
END
    return 0
}

# FIXME Rework app array.
# FIXME Does this need to get updated to el8? Check Google documentation.
# FIXME Need to check the arch here, only supporting intel...
# FIXME Add function for this...koopa::assert_is_intel_x86_64
# FIXME Need a corresponding assert koopa::assert_is_arm
koopa::fedora_add_google_cloud_sdk_repo() { # {{{1
    # """
    # Add Google Cloud SDK repo.
    # @note Updated 2021-11-02.
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
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    # FIXME koopa::assert_is_x86_64 (or koopa::assert_is_intel)
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [tee]="$(koopa::locate_tee)"
    )
    declare -A dict=(
        [arch]='x86_64'
        [enabled]=1
        [file]='/etc/yum.repos.d/google-cloud-sdk.repo'
        [gpgcheck]=1
        [repo_gpgcheck]=0
    )
    if koopa::is_rhel_7_like
    then
        dict[platform]='el7'
    else
        dict[platform]='el8'
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

koopa::fedora_import_azure_cli_key() { # {{{1
    # """
    # Import the Microsoft Azure CLI public key.
    # @note Updated 2021-11-02.
    # """
    local app dict
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A app=(
        [rpm]="$(koopa::fedora_locate_rpm)"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [key]='https://packages.microsoft.com/keys/microsoft.asc'
    )
    "${app[sudo]}" "${app[rpm]}" --import "${dict[key]}"
    return 0
}
