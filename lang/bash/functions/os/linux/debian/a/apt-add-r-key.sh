#!/usr/bin/env bash

koopa_debian_apt_add_r_key() {
    # """
    # Add the R key.
    # @note Updated 2024-06-27.
    #
    # Addition of signing key via keyserver directly into /etc/apt/trusted.gpg'
    # file is deprecated in Debian, but currently the only supported method for
    # installation of R CRAN binaries. Consider reworking this approach for
    # future R releases, if possible.
    #
    # @section Previous archive key:
    #
    # Additional archive key (required as of 2020-09): 'FCAE2A0E115C3D8A'
    #
    # @seealso
    # - https://cran.r-project.org/bin/linux/debian/
    # - https://cran.r-project.org/bin/linux/ubuntu/
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    dict['key_name']='r'
    # Alternatively, can use 'keys.gnupg.net' keyserver.
    dict['keyserver']='keyserver.ubuntu.com'
    dict['prefix']="$(koopa_debian_apt_key_prefix)"
    dict['file']="${dict['prefix']}/koopa-${dict['key_name']}.gpg"
    if koopa_is_ubuntu_like
    then
        # Ubuntu release is signed by Michael Rutter <marutter@gmail.com>.
        dict['key']='E298A3A825C0D65DFD57CBB651716619E084DAB9'
    else
        # Debian release is signed by Johannes Ranke <jranke@uni-bremen.de>.
        dict['key']='95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
    fi
    [[ -f "${dict['file']}" ]] && return 0
    koopa_gpg_download_key_from_keyserver \
        --file="${dict['file']}" \
        --key="${dict['key']}" \
        --keyserver="${dict['keyserver']}" \
        --sudo
    return 0
}
