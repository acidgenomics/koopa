#!/usr/bin/env bash

# FIXME Likely need to update the version here.
koopa::fedora_install_oracle_instantclient() { # {{{1
    # """
    # Install Oracle InstantClient.
    # @note Updated 2021-06-16.
    # @seealso
    # - https://www.oracle.com/database/technologies/
    #     instant-client/downloads.html
    # """
    local arch minor_version name name_fancy stem stems tmp_dir
    local url_prefix version
    koopa::assert_has_no_args "$#"
    name='oracle-instantclient'
    name_fancy='Oracle Instant Client'
    version="$(koopa::variable "$name")"
    minor_version="$(koopa::major_minor_version "$version")"
    arch="$(koopa::arch)"
    koopa::install_start "$name_fancy"
    koopa::fedora_dnf_install 'libaio-devel'
    # FIXME Need to create a stripped version string here...
    # '21.1.0.0.0' to '211000'.
    url_prefix="https://download.oracle.com/otn_software/linux/\
instantclient/195000"
    # FIXME Need to update version:
    # https://download.oracle.com/otn_software/linux/instantclient/211000/instantclient-basic-linux.x64-21.1.0.0.0.zip
    stems=('basic' 'devel' 'sqlplus' 'jdbc' 'odbc')
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        for stem in "${stems[@]}"
        do
            file="oracle-instantclient\
${minor_version}-${stem}-${version}.${arch}.rpm"
            koopa::download "${url_prefix}/${file}"
            # FIXME Can we make this a shared function?
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
