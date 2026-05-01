#!/usr/bin/env bash
# shellcheck disable=all

_koopa_rhel_enable_epel() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    if _koopa_fedora_dnf repolist \
        | _koopa_str_detect_regex - --pattern='^epel'
    then
        _koopa_alert_success 'EPEL is already enabled.'
        return 0
    fi
    _koopa_assert_is_admin
    dict['arch']="$(_koopa_arch)"
    dict['os_ver']="$(_koopa_linux_os_version)"
    dict['os_maj_ver']="$(_koopa_major_version "${dict['os_ver']}")"
    if ! _koopa_is_docker
    then
        app['sub_mngr']="$(_koopa_rhel_locate_subscription_manager)"
        _koopa_assert_is_executable "${app['sub_mngr']}"
        dict['sub_rpm']="codeready-builder-for-rhel-\
${dict['os_maj_ver']}-${dict['arch']}-rpms"
        "${app['sub_mngr']}" repos --enable "${dict['sub_rpm']}"
    fi
    _koopa_fedora_dnf_install "https://dl.fedoraproject.org/pub/epel/\
epel-release-latest-${dict['os_maj_ver']}.noarch.rpm"
    return 0
}

_koopa_rhel_locate_subscription_manager() {
    _koopa_locate_app '/usr/sbin/subscription-manager' "$@"
}
