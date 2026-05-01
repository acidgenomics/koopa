#!/usr/bin/env bash
# shellcheck disable=all

_koopa_fedora_dnf_delete_repo() {
    local file name
    _koopa_assert_has_args "$#"
    for name in "$@"
    do
        file="/etc/yum.repos.d/${name}.repo"
        _koopa_assert_is_file "$file"
        _koopa_rm --sudo "$file"
    done
    return 0
}

_koopa_fedora_dnf_install() {
    _koopa_fedora_dnf install "$@"
}

_koopa_fedora_dnf_remove() {
    _koopa_fedora_dnf remove "$@"
}

_koopa_fedora_dnf() {
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['dnf']="$(_koopa_fedora_locate_dnf)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['dnf']}" -y "$@"
    return 0
}

_koopa_fedora_install_from_rpm() {
    local -A app
    _koopa_assert_has_args "$#"
    _koopa_assert_is_admin
    app['rpm']="$(_koopa_fedora_locate_rpm)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo \
        "${app['rpm']}" \
            -v \
            --force \
            --install \
            "$@"
    return 0
}

_koopa_fedora_install_system_oracle_instant_client() {
    _koopa_assert_is_arm64
    _koopa_install_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

_koopa_fedora_install_system_rstudio_server() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

_koopa_fedora_install_system_shiny_server() {
    _koopa_install_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}

_koopa_fedora_locate_dnf() {
    _koopa_locate_app \
        '/usr/bin/dnf' \
        "$@"
}

_koopa_fedora_locate_rpm() {
    _koopa_locate_app \
        '/usr/bin/rpm' \
        "$@"
}

_koopa_fedora_set_locale() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    _koopa_assert_is_admin
    app['locale']="$(_koopa_locate_locale)"
    app['localedef']="$(_koopa_locate_localedef)"
    _koopa_assert_is_executable "${app[@]}"
    dict['lang']='en'
    dict['country']='US'
    dict['charset']='UTF-8'
    dict['lang_string']="${dict['lang']}_${dict['country']}.${dict['charset']}"
    _koopa_alert "Setting locale to '${dict['lang_string']}'."
    _koopa_sudo \
        "${app['localedef']}" \
            -i "${dict['lang']}_${dict['country']}" \
            -f "${dict['charset']}" \
            "${dict['lang_string']}"
    "${app['locale']}"
    _koopa_alert_success "Locale is defined as '${dict['lang_string']}'."
    return 0
}

_koopa_fedora_uninstall_system_oracle_instant_client() {
    _koopa_uninstall_app \
        --name='oracle-instant-client' \
        --platform='fedora' \
        --system \
        "$@"
}

_koopa_fedora_uninstall_system_rstudio_server() {
    _koopa_uninstall_app \
        --name='rstudio-server' \
        --platform='fedora' \
        --system \
        "$@"
}

_koopa_fedora_uninstall_system_shiny_server() {
    _koopa_uninstall_app \
        --name='shiny-server' \
        --platform='fedora' \
        --system \
        "$@"
}
