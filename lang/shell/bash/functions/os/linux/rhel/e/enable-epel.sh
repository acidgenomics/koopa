#!/usr/bin/env bash

koopa_rhel_enable_epel() {
    # """
    # Enable Extra Packages for Enterprise Linux (EPEL).
    # @note Updated 2023-01-06.
    #
    # @seealso
    # - https://docs.fedoraproject.org/en-US/epel/
    # """
    local -A app dict
    koopa_assert_has_no_args "$#"
    if koopa_fedora_dnf repolist \
        | koopa_str_detect_regex - --pattern='^epel'
    then
        koopa_alert_success 'EPEL is already enabled.'
        return 0
    fi
    koopa_assert_is_admin
    dict['arch']="$(koopa_arch)"
    dict['os_ver']="$(koopa_linux_os_version)"
    dict['os_maj_ver']="$(koopa_major_version "${dict['os_ver']}")"
    if ! koopa_is_docker
    then
        app['sub_mngr']="$(koopa_rhel_locate_subscription_manager)"
        koopa_assert_is_executable "${app['sub_mngr']}"
        dict['sub_rpm']="codeready-builder-for-rhel-\
${dict['os_maj_ver']}-${dict['arch']}-rpms"
        "${app['sub_mngr']}" repos --enable "${dict['sub_rpm']}"
    fi
    koopa_fedora_dnf_install "https://dl.fedoraproject.org/pub/epel/\
epel-release-latest-${dict['os_maj_ver']}.noarch.rpm"
    return 0
}
