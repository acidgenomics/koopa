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
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['dnf']="$(koopa_fedora_locate_dnf)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['dnf']}" -y "$@"
    return 0
}

koopa_fedora_install_from_rpm() {
    local -A app
    koopa_assert_has_args "$#"
    koopa_assert_is_admin
    app['rpm']="$(koopa_fedora_locate_rpm)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo \
        "${app['rpm']}" \
            -v \
            --force \
            --install \
            "$@"
    return 0
}

koopa_fedora_install_system_oracle_instant_client() {
    koopa_assert_is_aarch64
    koopa_install_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_install_system_rstudio_server() {
    koopa_assert_is_not_aarch64
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
    local -A app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    app['locale']="$(koopa_locate_locale)"
    app['localedef']="$(koopa_locate_localedef)"
    koopa_assert_is_executable "${app[@]}"
    dict['lang']='en'
    dict['country']='US'
    dict['charset']='UTF-8'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    koopa_alert "Setting locale to '${dict['lang_string']}'."
    koopa_sudo \
        "${app['localedef']}" \
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
