#!/usr/bin/env bash

koopa_debian_apt_add_google_cloud_key() {
    # """
    # Add the Google Cloud key.
    # @note Updated 2021-11-09.
    #
    # @seealso
    # - https://cloud.google.com/sdk/docs/install#deb
    # - https://github.com/docker/docker.github.io/issues/11625
    # """
    koopa_assert_has_no_args "$#"
    koopa_debian_apt_add_key \
        --name-fancy='Google Cloud' \
        --name='google-cloud' \
        --url='https://packages.cloud.google.com/apt/doc/apt-key.gpg'
    return 0
}
