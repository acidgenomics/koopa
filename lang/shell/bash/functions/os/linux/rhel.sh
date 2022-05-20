#!/bin/sh
# shellcheck disable=all

koopa_rhel_enable_epel() {
    koopa_assert_has_no_args "$#"
    if koopa_fedora_dnf repolist \
        | koopa_str_detect_regex - --pattern='^epel'
    then
        koopa_alert_success 'EPEL is already enabled.'
        return 0
    fi
    koopa_fedora_dnf_install "https://dl.fedoraproject.org/pub/\
epel/epel-release-latest-8.noarch.rpm"
    return 0
}

koopa_rhel_install_base_system() {
    koopa_install_app \
        --name-fancy='Red Hat Enterprise Linux (RHEL) base system' \
        --name='install-base' \
        --platform='rhel' \
        --system \
        "$@"
}
