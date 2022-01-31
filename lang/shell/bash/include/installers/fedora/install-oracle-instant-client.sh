#!/usr/bin/env bash

koopa:::fedora_install_oracle_instant_client() { # {{{1
    # """
    # Install Oracle Instant Client.
    # @note Updated 2022-01-27.
    #
    # @seealso
    # - https://www.oracle.com/database/technologies/
    #     instant-client/downloads.html
    # """
    local dict stems
    koopa::assert_has_no_args "$#"
    koopa::assert_is_admin
    declare -A dict=(
        [arch]="$(koopa::arch)"
        [platform]='linux'
        [version]="${INSTALL_VERSION:?}"
    )
    # e.g. '21.1.0.0.0-1' to '211000'.
    dict[version2]="$(koopa::sub '-[0-9]+$' '' "${dict[version]}")"
    dict[version2]="$(koopa::gsub '\.' '' "${dict[version2]}")"
    dict[url_prefix]="https://download.oracle.com/otn_software/\
${dict[platform]}/instantclient/${dict[version2]}"
    koopa::fedora_dnf_install 'libaio-devel'
    stems=('basic' 'devel' 'sqlplus' 'jdbc' 'odbc')
    for stem in "${stems[@]}"
    do
        local file
        file="oracle-instantclient-${dict[stem]}-${dict[version]}.\
${dict[arch]}.rpm"
        koopa::download "${dict[url_prefix]}/${file}" "$file"
        koopa::fedora_install_from_rpm "$file"
    done
    return 0
}
