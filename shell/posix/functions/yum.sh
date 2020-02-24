#!/bin/sh
# shellcheck disable=SC2039

_koopa_yum_add_azure_cli_repo() {  # {{{1
    # """
    # Add Microsoft Azure CLI yum repo.
    # @note Updated 2020-02-24.
    #
    # Alternate approach:
    # > sudo sh -c 'echo -e "xxx"'
    #
    # Note that 'echo -e' supports escape sequence but isn't POSIX.
    # https://unix.stackexchange.com/questions/189787/
    local file
    file="/etc/yum.repos.d/azure-cli.repo"
    [ -f "$file" ] && return 0
    sudo tee "$file" > /dev/null << EOF
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
    return 0
}

_koopa_yum_add_google_cloud_sdk_repo() {  # {{{1
    # """
    # Add Google Cloud SDK yum repo.
    # @note Updated 2020-02-24.
    #
    # Spacing is important in the 'gpgkey' section.
    #
    # @seealso
    # https://cloud.google.com/sdk/docs/downloads-yum
    # """
    local file
    file="/etc/yum.repos.d/google-cloud-sdk.repo"
    [ -f "$file" ] && return 0
    sudo tee "$file" > /dev/null << EOF
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

    return 0
}

_koopa_yum_import_azure_cli_key() {  # {{{1
    # """
    # Import the Microsoft Azure CLI public key.
    # @note Updated 2020-02-24.
    # """
    sudo rpm --import "https://packages.microsoft.com/keys/microsoft.asc"
    return 0
}
