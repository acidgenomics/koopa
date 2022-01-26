#!/usr/bin/env bash

# FIXME Should our main installer include an additional option to skip
# an installed program? Can pass in the function directly...
# FIXME Need to wrap this.
koopa::fedora_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2021-06-16.
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    # """
    
    local name_fancy
    name_fancy='Google Cloud SDK'
    if koopa::is_installed 'gcloud'
    then
        koopa::alert_is_installed "$name_fancy"
        return 0
    fi
    koopa::alert_install_start "$name_fancy"
    koopa::fedora_add_google_cloud_sdk_repo
    koopa::fedora_dnf_install 'google-cloud-sdk'
    koopa::alert_install_success "$name_fancy"
    return 0
}

# FIXME Need to wrap this.
koopa::fedora_uninstall_google_cloud_sdk() { # {{{1
    # """
    # Uninstall Google Cloud SDK.
    # @note Updated 2021-06-16.
    # """
    local name
    name='google-cloud-sdk'
    koopa::fedora_dnf_remove "$name"
    koopa::fedora_dnf_delete_repo "$name"
    return 0
}
