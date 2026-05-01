#!/usr/bin/env bash
# shellcheck disable=all

_koopa_linux_add_user_to_etc_passwd() {
    local -A dict
    _koopa_assert_has_args_le "$#" 1
    dict['passwd_file']='/etc/passwd'
    dict['user']="${1:-}"
    _koopa_assert_is_file "${dict['passwd_file']}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(_koopa_user_name)"
    if ! _koopa_file_detect_fixed \
        --file="${dict['passwd_file']}" \
        --pattern="${dict['user']}" \
        --sudo
    then
        _koopa_alert "Updating '${dict['passwd_file']}' to \
include '${dict['user']}'."
        dict['user_string']="$(getent passwd "${dict['user']}")"
        _koopa_sudo_append_string \
            --file="${dict['passwd_file']}" \
            --string="${dict['user_string']}"
    else
        _koopa_alert_note "'${dict['user']}' already defined \
in '${dict['passwd_file']}'."
    fi
    return 0
}

_koopa_linux_add_user_to_group() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(_koopa_linux_locate_gpasswd)"
    _koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(_koopa_user_name)"
    _koopa_alert "Adding user '${dict['user']}' to group '${dict['group']}'."
    _koopa_sudo \
        "${app['gpasswd']}" \
            --add "${dict['user']}" "${dict['group']}"
    return 0
}

_koopa_linux_aws_ec2_instance_id() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['ec2_metadata']="$(_koopa_linux_locate_ec2_metadata)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['ec2_metadata']}" --instance-id)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_linux_aws_ec2_instance_type() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['ec2_metadata']="$(_koopa_linux_locate_ec2_metadata)"
    _koopa_assert_is_executable "${app[@]}"
    dict['string']="$("${app['ec2_metadata']}" --instance-type)"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_linux_aws_ec2_stop() {
    local -A app dict
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['id']="$(_koopa_linux_aws_ec2_instance_id)"
    [[ -n "${dict['id']}" ]] || return 1
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    _koopa_alert "Stopping EC2 instance '${dict['id']}'."
    "${app['aws']}" ec2 stop-instances \
        --instance-ids "${dict['id']}" \
        --no-cli-pager \
        --output 'text' \
        --profile "${dict['profile']}"
    return 0
}

_koopa_linux_aws_ec2_terminate() {
    local -A app dict
    app['aws']="$(_koopa_locate_aws)"
    _koopa_assert_is_executable "${app[@]}"
    dict['id']="$(_koopa_linux_aws_ec2_instance_id)"
    [[ -n "${dict['id']}" ]] || return 1
    dict['profile']="${AWS_PROFILE:-default}"
    while (("$#"))
    do
        case "$1" in
            '--profile='*)
                dict['profile']="${1#*=}"
                shift 1
                ;;
            '--profile')
                dict['profile']="${2:?}"
                shift 2
                ;;
            *)
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_assert_is_set '--profile or AWS_PROFILE' "${dict['profile']}"
    "${app['aws']}" ec2 terminate-instances \
        --instance-ids "${dict['id']}" \
        --no-cli-pager \
        --output 'text' \
        --profile "${dict['profile']}"
    return 0
}

_koopa_linux_bcl2fastq_indrops() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['bcl2fastq']="$(_koopa_linux_locate_bcl2fastq)"
    app['tee']="$(_koopa_locate_tee --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['log_file']='bcl2fastq-indrops.log'
    "${app['bcl2fastq']}" \
        --use-bases-mask 'y*,y*,y*,y*' \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

_koopa_linux_configure_system_lmod() {
    _koopa_configure_app \
        --name='lmod' \
        --platform='linux' \
        --system \
        "$@"
}

_koopa_linux_configure_system_rstudio_server() {
    _koopa_configure_app \
        --name='rstudio-server' \
        --platform='linux' \
        --system \
        "$@"
}

_koopa_linux_configure_system_sshd() {
    _koopa_configure_app \
        --name='sshd' \
        --platform='linux' \
        --system \
        "$@"
}

_koopa_linux_delete_cache() {
    _koopa_assert_has_no_args "$#"
    if ! _koopa_is_docker
    then
        _koopa_stop 'Cache removal only supported inside Docker images.'
    fi
    _koopa_alert 'Removing caches, logs, and temporary files.'
    _koopa_rm --sudo \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if _koopa_is_debian_like
    then
        _koopa_rm --sudo '/var/lib/apt/lists/'*
    fi
    return 0
}

_koopa_linux_disable_root_password_expiration() {
    _koopa_assert_has_no_args "$#"
    _koopa_sudo -i chage -M 99999 root
    return 0
}

_koopa_linux_fix_sudo_setrlimit_error() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    dict['file']='/etc/sudo.conf'
    dict['string']='Set disable_coredump false'
    _koopa_sudo_append_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}

_koopa_linux_install_apptainer() {
    _koopa_install_app \
        --name='apptainer' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_aspera_connect() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_attr() {
    _koopa_install_app \
        --name='attr' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_cloudbiolinux() {
    _koopa_install_app \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_elfutils() {
    _koopa_install_app \
        --name='elfutils' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_gcc() {
    _koopa_install_app \
        --name='gcc' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_lmod() {
    _koopa_install_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_ont_bonito() {
    _koopa_install_app \
        --name='ont-bonito' \
        --platform='linux' \
        "$@"
}

_koopa_linux_install_private_bcl2fastq() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='bcl2fastq' \
        --platform='linux' \
        --private \
        "$@"
    _koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.illumina.com/sequencing/sequencing_software/\
bcl2fastq-conversion-software/downloads.html'."
    return 0
}

_koopa_linux_install_private_cellranger() {
    _koopa_assert_is_not_arm64
    _koopa_install_app \
        --name='cellranger' \
        --platform='linux' \
        --private \
        "$@"
    _koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.10xgenomics.com/single-cell-gene-expression/\
software/downloads/latest'."
    return 0
}

_koopa_linux_install_system_pihole() {
    _koopa_install_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

_koopa_linux_install_system_pivpn() {
    _koopa_install_app \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}

_koopa_linux_is_init_systemd() {
    [[ -d '/run/systemd/system' ]]
}

_koopa_linux_locate_bcl2fastq() {
    _koopa_locate_app \
        --app-name='bcl2fastq' \
        --bin-name='bcl2fastq' \
        "$@"
}

_koopa_linux_locate_ec2_metadata() {
    local app
    if _koopa_is_ubuntu_like
    then
        app='/usr/bin/ec2metadata'
    else
        app='/usr/bin/ec2-metadata'
    fi
    _koopa_locate_app "$app" "$@"
}

_koopa_linux_locate_getconf() {
    _koopa_locate_app \
        '/usr/bin/getconf' \
        "$@"
}

_koopa_linux_locate_gpasswd() {
    _koopa_locate_app \
        '/usr/bin/gpasswd' \
        "$@"
}

_koopa_linux_locate_groupadd() {
    _koopa_locate_app \
        '/usr/sbin/groupadd' \
        "$@"
}

_koopa_linux_locate_ldconfig() {
    local args
    args=()
    case "$(_koopa_os_id)" in
        'alpine' | \
        'debian')
            args+=('/sbin/ldconfig')
            ;;
        *)
            args+=('/usr/sbin/ldconfig')
            ;;
    esac
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_linux_locate_ldd() {
    _koopa_locate_app \
        '/usr/bin/ldd' \
        "$@"
}

_koopa_linux_locate_pihole() {
    _koopa_locate_app \
        '/usr/local/bin/pihole' \
        "$@"
}

_koopa_linux_locate_rstudio_server() {
    _koopa_locate_app \
        '/usr/sbin/rstudio-server' \
        "$@"
}

_koopa_linux_locate_shiny_server() {
    _koopa_locate_app \
        '/usr/bin/shiny-server' \
        "$@"
}

_koopa_linux_locate_sqlplus() {
    _koopa_locate_app \
        '/usr/bin/sqlplus' \
        "$@"
}

_koopa_linux_locate_systemctl() {
    local args
    args=()
    case "$(_koopa_os_id)" in
        'debian')
            args+=('/bin/systemctl')
            ;;
        *)
            args+=('/usr/bin/systemctl')
            ;;
    esac
    _koopa_locate_app "${args[@]}" "$@"
}

_koopa_linux_locate_useradd() {
    _koopa_locate_app \
        '/usr/sbin/useradd' \
        "$@"
}

_koopa_linux_locate_usermod() {
    _koopa_locate_app \
        '/usr/sbin/usermod' \
        "$@"
}

_koopa_linux_oracle_instantclient_version() {
    local -A app
    local str
    _koopa_assert_has_no_args "$#"
    app['sqlplus']="$(_koopa_linux_locate_sqlplus)"
    _koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['sqlplus']}" -v \
            | _koopa_grep --pattern='^Version' --regex \
            | _koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    _koopa_print "$str"
    return 0
}

_koopa_linux_os_version() {
    local -A app dict
    _koopa_assert_has_no_args "$#"
    app['awk']="$(_koopa_locate_awk --allow-system)"
    app['tr']="$(_koopa_locate_tr --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['key']='VERSION_ID'
    dict['file']='/etc/os-release'
    dict['string']="$( \
        "${app['awk']}" -F= \
            "\$1==\"${dict['key']}\" { print \$2 ;}" \
            "${dict['file']}" \
        | "${app['tr']}" -d '"' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    _koopa_print "${dict['string']}"
    return 0
}

_koopa_linux_proc_cmdline() {
    local -A app dict
    _koopa_assert_has_args_eq "$#" 1
    app['cat']="$(_koopa_locate_cat --allow-system)"
    app['echo']="$(_koopa_locate_echo --allow-system)"
    app['xargs']="$(_koopa_locate_xargs --allow-system)"
    _koopa_assert_is_executable "${app[@]}"
    dict['pid']="${1:?}"
    dict['cmdline']="/proc/${dict['pid']}/cmdline"
    _koopa_assert_is_file "${dict['cmdline']}"
    "${app['cat']}" "${dict['cmdline']}" \
        | "${app['xargs']}" -0 "${app['echo']}"
    return 0
}

_koopa_linux_profile_d_file() {
    _koopa_print '/etc/profile.d/zzz-koopa.sh'
    return 0
}

_koopa_linux_remove_user_from_group() {
    local -A app dict
    _koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(_koopa_linux_locate_gpasswd)"
    _koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(_koopa_user_name)"
    _koopa_sudo \
        "${app['gpasswd']}" \
            --delete "${dict['user']}" "${dict['group']}"
    return 0
}

_koopa_linux_uninstall_apptainer() {
    _koopa_uninstall_app \
        --name='apptainer' \
        "$@"
}

_koopa_linux_uninstall_aspera_connect() {
    _koopa_uninstall_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_attr() {
    _koopa_uninstall_app \
        --name='attr' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_bcbio_nextgen() {
    _koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_private_bcl2fastq() {
    _koopa_uninstall_app \
        --name='bcl2fastq' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_cloudbiolinux() {
    _koopa_uninstall_app \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_elfutils() {
    _koopa_uninstall_app \
        --name='elfutils' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_gcc() {
    _koopa_uninstall_app \
        --name='gcc' \
        "$@"
}

_koopa_linux_uninstall_lmod() {
    _koopa_uninstall_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_ont_bonito() {
    _koopa_uninstall_app \
        --name='ont-bonito' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_private_cellranger() {
    _koopa_uninstall_app \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}

_koopa_linux_uninstall_system_pihole() {
    _koopa_uninstall_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

_koopa_linux_uninstall_system_pivpn() {
    _koopa_uninstall_app \
        --name='pivpn' \
        --system \
        "$@"
}

_koopa_linux_update_ldconfig() {
    local -A app
    _koopa_assert_has_no_args "$#"
    app['ldconfig']="$(_koopa_linux_locate_ldconfig)"
    _koopa_assert_is_executable "${app[@]}"
    _koopa_sudo "${app['ldconfig']}" || true
    return 0
}

_koopa_linux_update_profile_d() {
    local -A dict
    _koopa_assert_has_no_args "$#"
    _koopa_is_shared_install || return 0
    _koopa_assert_is_admin
    dict['_koopa_prefix']="$(_koopa_koopa_prefix)"
    dict['file']="$(_koopa_linux_profile_d_file)"
    dict['today']="$(_koopa_today)"
    if [[ -f "${dict['file']}" ]] && [[ ! -L "${dict['file']}" ]]
    then
        return 0
    fi
    _koopa_alert "Adding koopa activation to '${dict['file']}'."
    _koopa_rm --sudo "${dict['file']}"
    read -r -d '' "dict[string]" << END || true
_koopa_activate_shared_profile() {
    if [ -f '${dict['_koopa_prefix']}/activate' ]
    then
        . '${dict['_koopa_prefix']}/activate'
    fi
    return 0
}

_koopa_activate_shared_profile
END
    _koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
}
