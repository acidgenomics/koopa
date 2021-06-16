#!/usr/bin/env bash

# FIXME Need to add support for Debian.

koopa::fedora_install_oracle_instantclient() { # {{{1
    # """
    # Install Oracle InstantClient.
    # @note Updated 2021-06-16.
    # @seealso
    # - https://www.oracle.com/database/technologies/
    #     instant-client/downloads.html
    # """
    local arch name name_fancy platform stem stems tmp_dir
    local url_prefix version version2
    koopa::assert_has_no_args "$#"
    name='oracle-instantclient'
    name_fancy='Oracle Instant Client'
    version="$(koopa::variable "$name")"
    platform='linux'
    arch="$(koopa::arch)"
    koopa::install_start "$name_fancy"
    koopa::fedora_dnf_install 'libaio-devel'
    # e.g. '21.1.0.0.0-1' to '211000'.
    version2="$(koopa::sub '-[0-9]+$' '' "$version")"
    version2="$(koopa::gsub '\.' '' "$version2")"
    url_prefix="https://download.oracle.com/otn_software/${platform}/\
instantclient/${version2}"
    # Expected:
    # https://download.oracle.com/otn_software/linux/instantclient/211000/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
    # Current:
    # https://download.oracle.com/otn_software/linux/instantclient/211000-1/oracle-instantclient-basic-21.1.0.0.0-1.x86_64.rpm
    stems=('basic' 'devel' 'sqlplus' 'jdbc' 'odbc')
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        for stem in "${stems[@]}"
        do
            file="${name}-${stem}-${version}.${arch}.rpm"
            koopa::download "${url_prefix}/${file}"
            # FIXME Do we need to extract the ZIP first?
            # FIXME Can we make this a shared function with other custom RPM installs?
            sudo rpm -i "$file"
        done
    )
    koopa::install_success "$name_fancy"
    return 0
}

koopa::fedora_uninstall_oracle_instantclient() { # {{{1
    # """
    # Uninstall Oracle InstantClient.
    # @note Updated 2021-06-16.
    # """
    koopa::fedora_dnf_remove 'oracle-instantclient*'
    koopa::rm -S '/etc/ld.so.conf.d/oracle-instantclient.conf'
}
