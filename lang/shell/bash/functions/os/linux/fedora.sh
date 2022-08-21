#!/bin/sh
# shellcheck disable=all

koopa_fedora_add_azure_cli_repo() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        [file]='/etc/yum.repos.d/azure-cli.repo'
    )
    [[ -f "${dict['file']}" ]] && return 0
    "${app['sudo']}" "${app['tee']}" "${dict['file']}" >/dev/null << END
[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
END
    return 0
}

koopa_fedora_add_google_cloud_sdk_repo() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [tee]="$(koopa_locate_tee)"
    )
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['tee']}" ]] || return 1
    declare -A dict=(
        [arch]="$(koopa_arch)"
        [enabled]=1
        [file]='/etc/yum.repos.d/google-cloud-sdk.repo'
        [gpgcheck]=1
        [repo_gpgcheck]=0
    )
    case "${dict['arch']}" in
        'x86_64')
            ;;
        *)
            koopa_stop 'Unsupported architecture.'
            ;;
    esac
    if koopa_is_fedora || koopa_is_rhel_8_like
    then
        dict[platform]='el8'
    elif koopa_is_rhel_7_like
    then
        dict[platform]='el7'
    else
        koopa_stop 'Unsupported platform.'
    fi
    dict[baseurl]="https://packages.cloud.google.com/yum/repos/\
cloud-sdk-${dict['platform']}-${dict['arch']}"
    [[ -f "${dict['file']}" ]] && return 0
    "${app['sudo']}" "${app['tee']}" "${dict['file']}" >/dev/null << END
[google-cloud-sdk]
name=Google Cloud SDK
baseurl=${dict['baseurl']}
enabled=${dict['enabled']}
gpgcheck=${dict['gpgcheck']}
repo_gpgcheck=${dict['repo_gpgcheck']}
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
       https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
END
    return 0
}

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
        [dnf]="$(koopa_fedora_locate_dnf)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['dnf']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    "${app['sudo']}" "${app['dnf']}" -y "$@"
    return 0
}

koopa_fedora_import_azure_cli_key() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [rpm]="$(koopa_fedora_locate_rpm)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['rpm']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    declare -A dict=(
        [key]='https://packages.microsoft.com/keys/microsoft.asc'
    )
    "${app['sudo']}" "${app['rpm']}" --import "${dict['key']}"
    return 0
}

koopa_fedora_install_bcl2fastq() {
    koopa_install_app \
        --link-in-bin='bcl2fastq' \
        --name='bcl2fastq' \
        --platform='fedora' \
        "$@"
}

koopa_fedora_install_from_rpm() {
    local app
    koopa_assert_has_args "$#"
    declare -A app=(
        [rpm]="$(koopa_fedora_locate_rpm)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['rpm']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    "${app['sudo']}" "${app['rpm']}" -v \
        --force \
        --install \
        "$@"
    return 0
}

koopa_fedora_install_system_azure_cli() {
    koopa_install_app \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_install_system_base() {
    koopa_install_app \
        --name='base' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_install_system_google_cloud_sdk() {
    koopa_install_app \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
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
    koopa_locate_app '/usr/bin/dnf'
}

koopa_fedora_locate_rpm() {
    koopa_locate_app '/usr/bin/rpm'
}

koopa_fedora_set_locale() {
    local app dict
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [locale]="$(koopa_locate_locale)"
        [localedef]="$(koopa_locate_localedef)"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app['locale']}" ]] || return 1
    [[ -x "${app['localedef']}" ]] || return 1
    [[ -x "${app['sudo']}" ]] || return 1
    declare -A dict=(
        [lang]='en'
        [country]='US'
        [charset]='UTF-8'
    )
    dict[lang_string]="${dict['lang']}_${dict['country']}.${dict['charset']}"
    koopa_alert "Setting locale to '${dict['lang_string']}'."
    "${app['sudo']}" "${app['localedef']}" \
        -i "${dict['lang']}_${dict['country']}" \
        -f "${dict['charset']}" \
        "${dict['lang_string']}"
    "${app['locale']}"
    koopa_alert_success "Locale is defined as '${dict['lang_string']}'."
    return 0
}

koopa_fedora_uninstall_system_azure_cli() {
    koopa_uninstall_app \
        --name='azure-cli' \
        --platform='fedora' \
        --system \
        "$@"
}

koopa_fedora_uninstall_system_google_cloud_sdk() {
    koopa_uninstall_app \
        --name='google-cloud-sdk' \
        --platform='fedora' \
        --system \
        "$@"
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
