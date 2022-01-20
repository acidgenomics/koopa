#!/usr/bin/env bash

# FIXME Need to wrap this.
# FIXME Rework using app/dict approach.
koopa::linux_update_google_cloud_sdk() { # {{{1
    # """
    # Update Google Cloud SDK.
    # @note Updated 2021-09-20.
    # """
    local gcloud name_fancy
    koopa::assert_has_no_args "$#"
    name_fancy='Google Cloud SDK'
    koopa::alert_update_start "$name_fancy"
    gcloud="$(koopa::locate_gcloud)"
    "$gcloud" components update
    koopa::alert_update_success "$name_fancy"
    return 0
}
