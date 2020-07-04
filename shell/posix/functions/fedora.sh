#!/bin/sh
# shellcheck disable=SC2039

_koopa_yum_add_azure_cli_repo() { # {{{1
    # """
    # Add Microsoft Azure CLI yum repo.
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    local file
    file="/etc/yum.repos.d/azure-cli.repo"
    [ -f "$file" ] && return 0
    sudo tee "$file" >/dev/null << END
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
END
    return 0
}

_koopa_yum_add_google_cloud_sdk_repo() { # {{{1
    # """
    # Add Google Cloud SDK yum repo.
    # @note Updated 2020-06-30.
    #
    # Spacing is important in the 'gpgkey' section.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    #
    # Installation on Amazon Linux 2:
    # - https://github.com/kubernetes/kubernetes/issues/60134
    # - https://github.com/GoogleCloudPlatform/google-fluentd/issues/136
    # """
    _koopa_assert_has_no_args "$#"
    local file gpgcheck
    file="/etc/yum.repos.d/google-cloud-sdk.repo"
    [ -f "$file" ] && return 0
    # Fix attempt for build error on CentOS 8 due to
    # 141 error code.
    gpgcheck=0
    repo_gpgcheck=0
    # > local repo_gpgcheck
    # > if _koopa_is_amzn
    # > then
    # >     repo_gpgcheck=0
    # > else
    # >     repo_gpgcheck=1
    # > fi
    sudo tee "$file" >/dev/null << END
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=${gpgcheck}
repo_gpgcheck=${repo_gpgcheck}
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
END
    return 0
}

_koopa_yum_import_azure_cli_key() { # {{{1
    # """
    # Import the Microsoft Azure CLI public key.
    # @note Updated 2020-06-30.
    # """
    _koopa_assert_has_no_args "$#"
    sudo rpm --import "https://packages.microsoft.com/keys/microsoft.asc"
    return 0
}
