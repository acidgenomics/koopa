#!/usr/bin/env bash

main() {
    # """
    # Install Oracle Instant Client.
    # @note Updated 2022-07-23.
    #
    # @section ROracle R package:
    #
    # Install basic, devel, jdbc, odbc, and sqlplus.
    # For Debian/Ubuntu, convert the RPM into DEB format using alien.
    #
    # See also:
    #
    # @seealso
    # - https://www.oracle.com/database/technologies/
    #     instant-client/downloads.html
    # - https://www.oracle.com/database/technologies/instant-client.html
    # - http://www.oracle.com/technetwork/database/features/instant-client/
    #       index-097480.html
    # - https://help.ubuntu.com/community/Oracle%20Instant%20Client
    # - https://docs.oracle.com/en/database/oracle/r-enterprise/1.5.1/oread/
    #       installing-oracle-database-instant-client.html
    #       #GUID-A61C2824-B9C7-4344-A7A2-E7FE0F05695D
    # - http://cran.cnr.berkeley.edu/web/packages/ROracle/INSTALL
    # - https://docs.oracle.com/cd/E83411_01/OREAD/
    #       installing-rstudio-server.htm#OREAD223
    # """
    local dict stems
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        ['arch']="$(koopa_arch)"
        ['platform']='linux'
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    # e.g. '21.1.0.0.0-1' to '211000'.
    dict['version2']="$( \
        koopa_sub \
            --pattern='-[0-9]+$' \
            --replacement='' \
            "${dict['version']}" \
    )"
    dict['version2']="$( \
        koopa_gsub \
            --pattern='\.' \
            --replacement='' \
            "${dict['version2']}" \
    )"
    dict['url_prefix']="https://download.oracle.com/otn_software/\
${dict['platform']}/instantclient/${dict['version2']}"
    koopa_fedora_dnf_install 'libaio-devel'
    stems=('basic' 'devel' 'sqlplus' 'jdbc' 'odbc')
    for stem in "${stems[@]}"
    do
        local file
        file="oracle-instantclient-${dict['stem']}-${dict['version']}.\
${dict['arch']}.rpm"
        koopa_download "${dict['url_prefix']}/${file}" "$file"
        koopa_fedora_install_from_rpm "$file"
    done
    return 0
}
