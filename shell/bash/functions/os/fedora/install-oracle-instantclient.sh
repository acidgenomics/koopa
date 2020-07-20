#!/usr/bin/env bash

koopa::fedora_install_oracle_instantclient() { # {{{1
    # """
    # Install Oracle InstantClient.
    # @note Updated 2020-07-16.
    # @seealso
    # - https://www.oracle.com/database/technologies/instant-client/
    #       linux-x86-64-downloads.html
    # """
    local minor_version name name_fancy stem stems tmp_dir url_prefix version
    koopa::assert_has_no_args "$#"
    name='oracle-instantclient'
    name_fancy='Oracle Instant Client'
    version="$(koopa::variable "$name")"
    minor_version="$(koopa::major_minor_version "$version")"
    koopa::install_start "$name_fancy"
    koopa::note "Removing previous version, if applicable."
    sudo dnf -y remove 'oracle-instantclient*'
    koopa::rm -S '/etc/ld.so.conf.d/oracle-instantclient.conf'
    url_prefix="https://download.oracle.com/otn_software/linux/instantclient/195000"
    stems=('basic' 'devel' 'sqlplus' 'jdbc' 'odbc')
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        for stem in "${stems[@]}"
        do
            file="oracle-instantclient${minor_version}-${stem}-${version}.x86_64.rpm"
            koopa::download "${url_prefix}/${file}"
            sudo rpm -i "$file"
        done
    )
    koopa::install_success "$name_fancy"
    return 0
}

