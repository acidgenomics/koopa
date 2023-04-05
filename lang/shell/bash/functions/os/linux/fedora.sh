#!/usr/bin/env bash
# shellcheck disable=all

koopa_fedora_dnf_delete_repo() {
    local file name
    koopa_assert_has_args "$#"
    for name in "$@"
    do
        file="/etc/yum.repos.d/${name}.repo"
        koopa_assert_is_file "$file"
        koopa_rm --sudo "$file"
    done
    return 0
}

koopa_fedora_dnf_install() {
    koopa_fedora_dnf install "$@"
}

koopa_fedora_dnf_remove() {
    koopa_fedora_dnf remove "$@"
}

koopa_fedora_dnf() {
    local app
    declare -A app=(
        ['dnf']="$(koopa_fedora_locate_dnf)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['dnf']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['dnf']}" -y "$@"
    return 0
}

koopa_fedora_install_private_bcl2fastq() {
    koopa_install_app \
        --name='bcl2fastq' \
        --platform='fedora' \
        --private \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.illumina.com/sequencing/sequencing_software/\
bcl2fastq-conversion-software/downloads.html'."
    return 0
}

koopa_fedora_install_from_rpm() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        ['rpm']="$(koopa_fedora_locate_rpm)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['rpm']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    "${app['sudo']}" "${app['rpm']}" -v \
        --force \
        --install \
        "$@"
    return 0
}

koopa_fedora_install_system_oracle_instant_client() {
    koopa_install_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_install_system_rstudio_server() {
    koopa_install_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_install_system_shiny_server() {
    koopa_install_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_locate_dnf() {
    koopa_locate_app \
        '/usr/bin/dnf' \
        "$@"
}

koopa_fedora_locate_rpm() {
    koopa_locate_app \
        '/usr/bin/rpm' \
        "$@"
}

koopa_fedora_set_locale() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        ['locale']="$(koopa_locate_locale)"
        ['localedef']="$(koopa_locate_localedef)"
        ['sudo']="$(koopa_locate_sudo)"
    )
    [[ -x "${app['locale']}" ]] || exit 1
    [[ -x "${app['localedef']}" ]] || exit 1
    [[ -x "${app['sudo']}" ]] || exit 1
    declare -A dict=(
        ['lang']='en'
        ['country']='US'
        ['charset']='UTF-8'
    )
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    koopa_alert "Setting locale to '${dict['lang_string']}'."
    "${app['sudo']}" "${app['localedef']}" \
        -i "${dict['lang']}_${dict['country']}" \
        -f "${dict['charset']}" \
        "${dict['lang_string']}"
    "${app['locale']}"
    koopa_alert_success "Locale is defined as '${dict['lang_string']}'."
    return 0
}

koopa_fedora_uninstall_system_oracle_instant_client() {
    koopa_uninstall_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_system_rstudio_server() {
    koopa_uninstall_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_system_shiny_server() {
    koopa_uninstall_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}
