#!/usr/bin/env bash
# shellcheck disable=all

koopa_linux_add_user_to_etc_passwd() {
    local -A dict
    koopa_assert_has_args_le "$#" 1
    dict['passwd_file']='/etc/passwd'
    dict['user']="${1:-}"
    koopa_assert_is_file "${dict['passwd_file']}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(koopa_user_name)"
    if ! koopa_file_detect_fixed \
        --file="${dict['passwd_file']}" \
        --pattern="${dict['user']}" \
        --sudo
    then
        koopa_alert "Updating '${dict['passwd_file']}' to \
include '${dict['user']}'."
        dict['user_string']="$(getent passwd "${dict['user']}")"
        koopa_sudo_append_string \
            --file="${dict['passwd_file']}" \
            --string="${dict['user_string']}"
    else
        koopa_alert_note "'${dict['user']}' already defined \
in '${dict['passwd_file']}'."
    fi
    return 0
}

koopa_linux_add_user_to_group() {
    local -A app dict
    koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(koopa_linux_locate_gpasswd)"
    koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(koopa_user_name)"
    koopa_alert "Adding user '${dict['user']}' to group '${dict['group']}'."
    koopa_sudo \
        "${app['gpasswd']}" \
            --add "${dict['user']}" "${dict['group']}"
    return 0
}

koopa_linux_bcbio_nextgen_add_ensembl_genome() {
    local -A app dict
    local -a indexes
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    app['bcbio_setup_genome']="$(koopa_linux_locate_bcbio_setup_genome)"
    app['sed']="$(koopa_locate_sed --allow-system)"
    app['touch']="$(koopa_locate_touch)"
    koopa_assert_is_executable "${app[@]}"
    dict['cores']="$(koopa_cpu_count)"
    dict['fasta_file']=''
    dict['genome_build']=''
    dict['gtf_file']=''
    dict['organism']=''
    dict['organism_pattern']='^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    dict['provider']='Ensembl'
    dict['release']=''
    indexes=()
    while (("$#"))
    do
        case "$1" in
            '--fasta-file='*)
                dict['fasta_file']="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict['fasta_file']="${2:?}"
                shift 2
                ;;
            '--genome-build='*)
                dict['genome_build']="${1#*=}"
                shift 1
                ;;
            '--genome-build')
                dict['genome_build']="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict['gtf_file']="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict['gtf_file']="${2:?}"
                shift 2
                ;;
            '--indexes='*)
                indexes+=("${1#*=}")
                shift 1
                ;;
            '--indexes')
                indexes+=("${2:?}")
                shift 2
                ;;
            '--organism='*)
                dict['organism']="${1#*=}"
                shift 1
                ;;
            '--organism')
                dict['organism']="${2:?}"
                shift 2
                ;;
            '--release='*)
                dict['release']="${1#*=}"
                shift 1
                ;;
            '--release')
                dict['release']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fasta-file' "${dict['fasta_file']}" \
        '--genome-build' "${dict['genome_build']}" \
        '--gtf-file' "${dict['gtf_file']}" \
        '--index' "${indexes[*]}" \
        '--organism' "${dict['organism']}" \
        '--release' "${dict['release']}"
    koopa_assert_is_file "${dict['fasta_file']}" "${dict['gtf_file']}"
    dict['fasta_file']="$(koopa_realpath "${dict['fasta_file']}")"
    dict['gtf_file']="$(koopa_realpath "${dict['gtf_file']}")"
    if ! koopa_str_detect_regex \
        --string="${dict['organism']}" \
        --pattern="${dict['organism_pattern']}"
    then
        koopa_stop "Invalid organism: '${dict['organism']}'."
    fi
    dict['build_version']="${dict['provider']}_${dict['release']}"
    dict['bcbio_genome_name']="${dict['build']} \
${dict['provider']} ${dict['release']}"
    dict['bcbio_genome_name']="${dict['bcbio_genome_name']// /_}"
    koopa_alert_install_start "${dict['bcbio_genome_name']}"
    dict['bcbio_species_dir']="$( \
        koopa_print "${dict['organism']// /_}" \
            | "${app['sed']}" -E 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    dict['install_prefix']="$(koopa_parent_dir --num=3 "${dict['script']}")"
    dict['tool_data_prefix']="${dict['install_prefix']}/galaxy/tool-data"
    koopa_mkdir "${dict['tool_data_prefix']}"
    "${app['touch']}" "${dict['tool_data_prefix']}/sam_fa_indices.log"
    koopa_dl \
        'FASTA file' "${dict['fasta_file']}" \
        'GTF file' "${dict['gtf_file']}" \
        'Indexes' "${indexes[*]}"
    "${app['bcbio_setup_genome']}" \
        --build "${dict['bcbio_genome_name']}" \
        --buildversion "${dict['build_version']}" \
        --cores "${dict['cores']}" \
        --fasta "${dict['fasta_file']}" \
        --gtf "${dict['gtf_file']}" \
        --indexes "${indexes[@]}" \
        --name "${dict['bcbio_species_dir']}"
    koopa_alert_install_success "${dict['bcbio_genome_name']}"
    return 0
}

koopa_linux_bcbio_nextgen_add_genome() {
    local -A app dict
    local -a bcbio_args
    local genome
    koopa_assert_has_args "$#"
    app['bcbio']="$(koopa_linux_locate_bcbio)"
    koopa_assert_is_executable "${app[@]}"
    dict['cores']="$(koopa_cpu_count)"
    bcbio_args=(
        "--cores=${dict['cores']}"
        '--upgrade=skip'
    )
    for genome in "$@"
    do
        bcbio_args+=("--genomes=${genome}")
    done
    "${app['bcbio']}" upgrade "${bcbio_args[@]}"
    return 0
}

koopa_linux_bcbio_nextgen_patch_devel() {
    local -A app dict
    local -a cache_files
    koopa_assert_has_no_envs
    app['bcbio_python']="$(koopa_linux_locate_bcbio_python)"
    app['tee']="$(koopa_locate_tee)"
    koopa_assert_is_executable "${app[@]}"
    dict['git_dir']="${HOME:?}/git/bcbio-nextgen"
    dict['install_dir']=''
    dict['name']='bcbio-nextgen'
    dict['tmp_log_file']="$(koopa_tmp_log_file)"
    while (("$#"))
    do
        case "$1" in
            '--bcbio-python='*)
                app['bcbio_python']="${1#*=}"
                shift 1
                ;;
            '--bcbio-python')
                app['bcbio_python']="${2:?}"
                shift 2
                ;;
            '--git-dir='*)
                dict['git_dir']="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict['git_dir']="${2:?}"
                shift 2
                ;;
            '--install-dir='*)
                dict['install_dir']="${1#*=}"
                shift 1
                ;;
            '--install-dir')
                dict['install_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict['git_dir']}"
    if [[ -z "${dict['install_dir']}" ]]
    then
        dict['install_dir']="$( \
            koopa_parent_dir --num=3 "${app['bcbio_python']}" \
        )"
    fi
    koopa_assert_is_dir "${dict['install_dir']}"
    koopa_h1 "Patching '${dict['name']}' installation \
at '${dict['install_dir']}'."
    koopa_dl  \
        'Git dir' "${dict['git_dir']}" \
        'Install dir' "${dict['install_dir']}" \
        'bcbio_python' "${app['bcbio_python']}"
    koopa_alert "Removing Python cache in '${dict['git_dir']}'."
    readarray -t cache_files <<< "$( \
        koopa_find \
            --pattern='*.pyc' \
            --prefix="${dict['git_dir']}" \
            --type='f'
    )"
    koopa_rm "${cache_files[@]}"
    readarray -t cache_files <<< "$( \
        koopa_find \
            --pattern='__pycache__' \
            --prefix="${dict['git_dir']}" \
            --type='d'
    )"
    koopa_rm "${cache_files[@]}"
    koopa_alert "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa_rm "${dict['install_dir']}/anaconda/lib/python"*'/\
site-packages/bcbio'*
    (
        koopa_cd "${dict['git_dir']}"
        koopa_rm 'tests/test_automated_output'
        koopa_alert "Patching installation via 'setup.py' script."
        "${app['bcbio_python']}" setup.py install
    ) 2>&1 | "${app['tee']}" "${dict['tmp_log_file']}"
    koopa_alert_success "Patching of '${dict['name']}' was successful."
    return 0
}

koopa_linux_bcbio_nextgen_run_tests() {
    local -A dict
    local -a tests
    local test
    dict['git_dir']="${HOME:?}/git/bcbio-nextgen"
    dict['output_dir']="${PWD:?}/bcbio-tests"
    dict['tools_dir']="$(koopa_bcbio_nextgen_tools_prefix)"
    while (("$#"))
    do
        case "$1" in
            '--git-dir='*)
                dict['git_dir']="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict['git_dir']="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict['output_dir']="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict['output_dir']="${2:?}"
                shift 2
                ;;
            '--tools-dir='*)
                dict['tools_dir']="${1#*=}"
                shift 1
                ;;
            '--tools-dir')
                dict['tools_dir']="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict['git_dir']}" "${dict['tools_dir']}"
    koopa_mkdir "${dict['output_dir']}"
    (
        koopa_add_to_path_start "${dict['tools_dir']}/bin"
        koopa_cd "${dict['git_dir']}/tests"
        tests=(
            'fastrnaseq'
            'star'
            'hisat2'
            'rnaseq'
            'stranded'
            'chipseq'
            'scrnaseq' # single-cell RNA-seq.
            'srnaseq' # small RNA-seq (hanging inside Docker image).
        )
        for test in "${tests[@]}"
        do
            export BCBIO_TEST_DIR="${dict['output_dir']}/${test}"
            ./run_tests.sh "$test" --keep-test-dir
        done
    )
    koopa_alert_success "Unit tests passed for '${dict['tools_dir']}'."
    return 0
}

koopa_linux_bcl2fastq_indrops() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['bcl2fastq']="$(koopa_linux_locate_bcl2fastq)"
    app['tee']="$(koopa_locate_tee --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['log_file']='bcl2fastq-indrops.log'
    "${app['bcl2fastq']}" \
        --use-bases-mask 'y*,y*,y*,y*' \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | "${app['tee']}" "${dict['log_file']}"
    return 0
}

koopa_linux_configure_system_lmod() {
    koopa_configure_app \
        --name='lmod' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_configure_system_rstudio_server() {
    koopa_configure_app \
        --name='rstudio-server' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_configure_system_sshd() {
    koopa_configure_app \
        --name='sshd' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_delete_cache() {
    koopa_assert_has_no_args "$#"
    if ! koopa_is_docker
    then
        koopa_stop 'Cache removal only supported inside Docker images.'
    fi
    koopa_alert 'Removing caches, logs, and temporary files.'
    koopa_rm --sudo \
        '/root/.cache' \
        '/tmp/'* \
        '/var/backups/'* \
        '/var/cache/'*
    if koopa_is_debian_like
    then
        koopa_rm --sudo '/var/lib/apt/lists/'*
    fi
    return 0
}

koopa_linux_fix_sudo_setrlimit_error() {
    local -A dict
    koopa_assert_has_no_args "$#"
    dict['file']='/etc/sudo.conf'
    dict['string']='Set disable_coredump false'
    koopa_sudo_append_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
    return 0
}

koopa_linux_install_apptainer() {
    koopa_install_app \
        --name='apptainer' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_aspera_connect() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_attr() {
    koopa_install_app \
        --name='attr' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_bcbio_nextgen() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_cloudbiolinux() {
    koopa_install_app \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_elfutils() {
    koopa_install_app \
        --name='elfutils' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_lmod() {
    koopa_install_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_ont_bonito() {
    koopa_install_app \
        --name='ont-bonito' \
        --platform='linux' \
        "$@"
}

koopa_linux_install_private_bcl2fastq() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='bcl2fastq' \
        --platform='linux' \
        --private \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.illumina.com/sequencing/sequencing_software/\
bcl2fastq-conversion-software/downloads.html'."
    return 0
}

koopa_linux_install_private_cellranger() {
    koopa_assert_is_not_aarch64
    koopa_install_app \
        --name='cellranger' \
        --platform='linux' \
        --private \
        "$@"
    koopa_alert_note "Installation requires agreement to terms of service at: \
'https://support.10xgenomics.com/single-cell-gene-expression/\
software/downloads/latest'."
    return 0
}

koopa_linux_install_system_pihole() {
    koopa_install_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_install_system_pivpn() {
    koopa_install_app \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_is_init_systemd() {
    [[ -d '/run/systemd/system' ]]
}

koopa_linux_locate_bcbio_python() {
    koopa_locate_app \
        --app-name='bcbio-nextgen' \
        --bin-name='bcbio_python' \
        "$@"
}

koopa_linux_locate_bcbio_setup_genome() {
    koopa_locate_app \
        --app-name='bcbio-nextgen' \
        --bin-name='bcbio_setup_genome.py' \
        "$@"
}

koopa_linux_locate_bcbio() {
    koopa_locate_app \
        --app-name='bcbio-nextgen' \
        --bin-name='bcbio-nextgen.py' \
        "$@"
}

koopa_linux_locate_bcl2fastq() {
    koopa_locate_app \
        --app-name='bcl2fastq' \
        --bin-name='bcl2fastq' \
        "$@"
}

koopa_linux_locate_getconf() {
    koopa_locate_app \
        '/usr/bin/getconf' \
        "$@"
}

koopa_linux_locate_gpasswd() {
    koopa_locate_app \
        '/usr/bin/gpasswd' \
        "$@"
}

koopa_linux_locate_groupadd() {
    koopa_locate_app \
        '/usr/sbin/groupadd' \
        "$@"
}

koopa_linux_locate_ldconfig() {
    local args
    args=()
    case "$(koopa_os_id)" in
        'alpine' | \
        'debian')
            args+=('/sbin/ldconfig')
            ;;
        *)
            args+=('/usr/sbin/ldconfig')
            ;;
    esac
    koopa_locate_app "${args[@]}" "$@"
}

koopa_linux_locate_ldd() {
    koopa_locate_app \
        '/usr/bin/ldd' \
        "$@"
}

koopa_linux_locate_pihole() {
    koopa_locate_app \
        '/usr/local/bin/pihole' \
        "$@"
}

koopa_linux_locate_rstudio_server() {
    koopa_locate_app \
        '/usr/sbin/rstudio-server' \
        "$@"
}

koopa_linux_locate_shiny_server() {
    koopa_locate_app \
        '/usr/bin/shiny-server' \
        "$@"
}

koopa_linux_locate_sqlplus() {
    koopa_locate_app \
        '/usr/bin/sqlplus' \
        "$@"
}

koopa_linux_locate_systemctl() {
    local args
    args=()
    case "$(koopa_os_id)" in
        'debian')
            args+=('/bin/systemctl')
            ;;
        *)
            args+=('/usr/bin/systemctl')
            ;;
    esac
    koopa_locate_app "${args[@]}" "$@"
}

koopa_linux_locate_useradd() {
    koopa_locate_app \
        '/usr/sbin/useradd' \
        "$@"
}

koopa_linux_locate_usermod() {
    koopa_locate_app \
        '/usr/sbin/usermod' \
        "$@"
}

koopa_linux_oracle_instantclient_version() {
    local -A app
    local str
    koopa_assert_has_no_args "$#"
    app['sqlplus']="$(koopa_linux_locate_sqlplus)"
    koopa_assert_is_executable "${app[@]}"
    str="$( \
        "${app['sqlplus']}" -v \
            | koopa_grep --pattern='^Version' --regex \
            | koopa_extract_version \
    )"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_linux_os_version() {
    local -A app dict
    koopa_assert_has_no_args "$#"
    app['awk']="$(koopa_locate_awk --allow-system)"
    app['tr']="$(koopa_locate_tr --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['key']='VERSION_ID'
    dict['file']='/etc/os-release'
    dict['string']="$( \
        "${app['awk']}" -F= \
            "\$1==\"${dict['key']}\" { print \$2 ;}" \
            "${dict['file']}" \
        | "${app['tr']}" -d '"' \
    )"
    [[ -n "${dict['string']}" ]] || return 1
    koopa_print "${dict['string']}"
    return 0
}

koopa_linux_proc_cmdline() {
    local -A app dict
    koopa_assert_has_args_eq "$#" 1
    app['cat']="$(koopa_locate_cat --allow-system)"
    app['echo']="$(koopa_locate_echo --allow-system)"
    app['xargs']="$(koopa_locate_xargs --allow-system)"
    koopa_assert_is_executable "${app[@]}"
    dict['pid']="${1:?}"
    dict['cmdline']="/proc/${dict['pid']}/cmdline"
    koopa_assert_is_file "${dict['cmdline']}"
    "${app['cat']}" "${dict['cmdline']}" \
        | "${app['xargs']}" -0 "${app['echo']}"
    return 0
}

koopa_linux_remove_user_from_group() {
    local -A app dict
    koopa_assert_has_args_le "$#" 2
    app['gpasswd']="$(koopa_linux_locate_gpasswd)"
    koopa_assert_is_executable "${app[@]}"
    dict['group']="${1:?}"
    dict['user']="${2:-}"
    [[ -z "${dict['user']}" ]] && dict['user']="$(koopa_user_name)"
    koopa_sudo \
        "${app['gpasswd']}" \
            --delete "${dict['user']}" "${dict['group']}"
    return 0
}

koopa_linux_uninstall_apptainer() {
    koopa_uninstall_app \
        --name='apptainer' \
        "$@"
}

koopa_linux_uninstall_aspera_connect() {
    koopa_uninstall_app \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_attr() {
    koopa_uninstall_app \
        --name='attr' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_bcbio_nextgen() {
    koopa_uninstall_app \
        --name='bcbio-nextgen' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_private_bcl2fastq() {
    koopa_uninstall_app \
        --name='bcl2fastq' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_cloudbiolinux() {
    koopa_uninstall_app \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_elfutils() {
    koopa_uninstall_app \
        --name='elfutils' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_lmod() {
    koopa_uninstall_app \
        --name='lmod' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_ont_bonito() {
    koopa_uninstall_app \
        --name='ont-bonito' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_private_cellranger() {
    koopa_uninstall_app \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}

koopa_linux_uninstall_system_pihole() {
    koopa_uninstall_app \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}

koopa_linux_uninstall_system_pivpn() {
    koopa_uninstall_app \
        --name='pivpn' \
        --system \
        "$@"
}

koopa_linux_update_etc_profile_d() {
    local -A dict
    koopa_assert_has_no_args "$#"
    koopa_is_shared_install || return 0
    koopa_assert_is_admin
    dict['koopa_prefix']="$(koopa_koopa_prefix)"
    dict['file']='/etc/profile.d/zzz-koopa.sh'
    if [[ -f "${dict['file']}" ]] && [[ ! -L "${dict['file']}" ]]
    then
        return 0
    fi
    koopa_alert "Adding koopa activation to '${dict['file']}'."
    koopa_rm --sudo "${dict['file']}"
    read -r -d '' "dict[string]" << END || true

_koopa_activate_shared_profile() {
    . "${dict['koopa_prefix']}/activate"
    return 0
}

_koopa_activate_shared_profile
END
    koopa_sudo_write_string \
        --file="${dict['file']}" \
        --string="${dict['string']}"
}

koopa_linux_update_ldconfig() {
    local -A app
    koopa_assert_has_no_args "$#"
    app['ldconfig']="$(koopa_linux_locate_ldconfig)"
    koopa_assert_is_executable "${app[@]}"
    koopa_sudo "${app['ldconfig']}" || true
    return 0
}
