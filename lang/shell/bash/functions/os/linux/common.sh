#!/bin/sh
# shellcheck disable=all
koopa_linux_add_user_to_etc_passwd() {
    local dict
    koopa_assert_has_args_le "$#" 1
    declare -A dict=(
        [passwd_file]='/etc/passwd'
        [user]="${1:-}"
    )
    koopa_assert_is_file "${dict[passwd_file]}"
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa_user)"
    if ! koopa_file_detect_fixed \
        --file="${dict[passwd_file]}" \
        --pattern="${dict[user]}" \
        --sudo
    then
        koopa_alert "Updating '${dict[passwd_file]}' to \
include '${dict[user]}'."
        dict[user_string]="$(getent passwd "${dict[user]}")"
        koopa_sudo_append_string \
            --file="${dict[passwd_file]}" \
            --string="${dict[user_string]}"
    else
        koopa_alert_note "'${dict[user]}' already defined \
in '${dict[passwd_file]}'."
    fi
    return 0
}
koopa_linux_add_user_to_group() {
    local app dict
    koopa_assert_has_args_le "$#" 2
    koopa_assert_is_admin
    declare -A app=(
        [gpasswd]="$(koopa_linux_locate_gpasswd)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [group]="${1:?}"
        [user]="${2:-}"
    )
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa_user)"
    koopa_alert "Adding user '${dict[user]}' to group '${dict[group]}'."
    "${app[sudo]}" "${app[gpasswd]}" --add "${dict[user]}" "${dict[group]}"
    return 0
}
koopa_linux_bcbio_nextgen_add_ensembl_genome() {
    local app dict indexes
    koopa_assert_has_args "$#"
    koopa_assert_has_no_envs
    declare -A app=(
        [bcbio_setup_genome]='bcbio_setup_genome.py'
        [sed]="$(koopa_locate_sed)"
        [touch]="$(koopa_locate_touch)"
    )
    declare -A dict=(
        [cores]="$(koopa_cpu_count)"
        [fasta_file]=''
        [genome_build]=''
        [gtf_file]=''
        [organism]=''
        [organism_pattern]='^([A-Z][a-z]+)(\s|_)([a-z]+)$'
        [provider]='Ensembl'
        [release]=''
    )
    indexes=()
    while (("$#"))
    do
        case "$1" in
            '--fasta-file='*)
                dict[fasta_file]="${1#*=}"
                shift 1
                ;;
            '--fasta-file')
                dict[fasta_file]="${2:?}"
                shift 2
                ;;
            '--genome-build='*)
                dict[genome_build]="${1#*=}"
                shift 1
                ;;
            '--genome-build')
                dict[genome_build]="${2:?}"
                shift 2
                ;;
            '--gtf-file='*)
                dict[gtf_file]="${1#*=}"
                shift 1
                ;;
            '--gtf-file')
                dict[gtf_file]="${2:?}"
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
                dict[organism]="${1#*=}"
                shift 1
                ;;
            '--organism')
                dict[organism]="${2:?}"
                shift 2
                ;;
            '--release='*)
                dict[release]="${1#*=}"
                shift 1
                ;;
            '--release')
                dict[release]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--fasta-file' "${dict[fasta_file]}" \
        '--genome-build' "${dict[genome_build]}" \
        '--gtf-file' "${dict[gtf_file]}" \
        '--index' "${indexes[*]}" \
        '--organism' "${dict[organism]}" \
        '--release' "${dict[release]}"
    koopa_activate_bcbio_nextgen
    koopa_assert_is_installed "${app[bcbio_setup_genome]}"
    koopa_assert_is_file "${dict[fasta_file]}" "${dict[gtf_file]}"
    dict[fasta_file]="$(koopa_realpath "${dict[fasta_file]}")"
    dict[gtf_file]="$(koopa_realpath "${dict[gtf_file]}")"
    if ! koopa_str_detect_regex \
        --string="${dict[organism]}" \
        --pattern="${dict[organism_pattern]}"
    then
        koopa_stop "Invalid organism: '${dict[organism]}'."
    fi
    dict[build_version]="${dict[provider]}_${dict[release]}"
    dict[bcbio_genome_name]="${dict[build]} ${dict[provider]} ${dict[release]}"
    dict[bcbio_genome_name]="${dict[bcbio_genome_name]// /_}"
    koopa_alert_install_start "${dict[bcbio_genome_name]}"
    dict[bcbio_species_dir]="$( \
        koopa_print "${dict[organism]// /_}" \
            | "${app[sed]}" -E 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    dict[install_prefix]="$(koopa_parent_dir --num=3 "${dict[script]}")"
    dict[tool_data_prefix]="${dict[install_prefix]}/galaxy/tool-data"
    koopa_mkdir "${dict[tool_data_prefix]}"
    "${app[touch]}" "${dict[tool_data_prefix]}/sam_fa_indices.log"
    koopa_dl \
        'FASTA file' "${dict[fasta_file]}" \
        'GTF file' "${dict[gtf_file]}" \
        'Indexes' "${indexes[*]}"
    "${app[bcbio_setup_genome]}" \
        --build "${dict[bcbio_genome_name]}" \
        --buildversion "${dict[build_version]}" \
        --cores "${dict[cores]}" \
        --fasta "${dict[fasta_file]}" \
        --gtf "${dict[gtf_file]}" \
        --indexes "${indexes[@]}" \
        --name "${dict[bcbio_species_dir]}"
    koopa_alert_install_success "${dict[bcbio_genome_name]}"
    return 0
}
koopa_linux_bcbio_nextgen_add_genome() {
    local app bcbio_args dict genome genomes
    koopa_assert_has_args "$#"
    genomes=("$@")
    declare -A app=(
        [bcbio]="$(koopa_linux_locate_bcbio)"
    )
    declare -A dict=(
        [cores]="$(koopa_cpu_count)"
    )
    bcbio_args=(
        "--cores=${dict[cores]}"
        '--upgrade=skip'
    )
    for genome in "${genomes[@]}"
    do
        bcbio_args+=("--genomes=${genome}")
    done
    koopa_dl \
        'Genomes' "$(koopa_to_string "${genomes[@]}")" \
        'Args' "${bcbio_args[@]}"
    "${app[bcbio]}" upgrade "${bcbio_args[@]}"
    return 0
}
koopa_linux_bcbio_nextgen_patch_devel() {
    local app cache_files dict
    koopa_assert_has_no_envs
    declare -A app=(
        [bcbio_python]='bcbio_python'
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [git_dir]="${HOME:?}/git/bcbio-nextgen"
        [install_dir]=''
        [name_fancy]='bcbio-nextgen'
        [tmp_log_file]="$(koopa_tmp_log_file)"
    )
    while (("$#"))
    do
        case "$1" in
            '--bcbio-python='*)
                app[bcbio_python]="${1#*=}"
                shift 1
                ;;
            '--bcbio-python')
                app[bcbio_python]="${2:?}"
                shift 2
                ;;
            '--git-dir='*)
                dict[git_dir]="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict[git_dir]="${2:?}"
                shift 2
                ;;
            '--install-dir='*)
                dict[install_dir]="${1#*=}"
                shift 1
                ;;
            '--install-dir')
                dict[install_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[git_dir]}"
    if [[ ! -x "${app[bcbio_python]}" ]]
    then
        koopa_locate_app "${app[bcbio_python]}"
    fi
    app[bcbio_python]="$(koopa_realpath "${app[bcbio_python]}")"
    koopa_assert_is_installed "${app[bcbio_python]}"
    if [[ -z "${dict[install_dir]}" ]]
    then
        dict[install_dir]="$(koopa_parent_dir --num=3 "${app[bcbio_python]}")"
    fi
    koopa_assert_is_dir "${dict[install_dir]}"
    koopa_h1 "Patching ${dict[name_fancy]} installation at \
'${dict[install_dir]}'."
    koopa_dl  \
        'Git dir' "${dict[git_dir]}" \
        'Install dir' "${dict[install_dir]}" \
        'bcbio_python' "${app[bcbio_python]}"
    koopa_alert "Removing Python cache in '${dict[git_dir]}'."
    readarray -t cache_files <<< "$( \
        koopa_find \
            --pattern='*.pyc' \
            --prefix="${dict[git_dir]}" \
            --type='f'
    )"
    koopa_rm "${cache_files[@]}"
    readarray -t cache_files <<< "$( \
        koopa_find \
            --pattern='__pycache__' \
            --prefix="${dict[git_dir]}" \
            --type='d'
    )"
    koopa_rm "${cache_files[@]}"
    koopa_alert "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa_rm "${dict[install_dir]}/anaconda/lib/python"*'/site-packages/bcbio'*
    (
        koopa_cd "${dict[git_dir]}"
        koopa_rm 'tests/test_automated_output'
        koopa_alert "Patching installation via 'setup.py' script."
        "${app[bcbio_python]}" setup.py install
    ) 2>&1 | "${app[tee]}" "${dict[tmp_log_file]}"
    koopa_alert_success "Patching of ${dict[name_fancy]} was successful."
    return 0
}
koopa_linux_bcbio_nextgen_run_tests() {
    local dict test tests
    declare -A dict=(
        [git_dir]="${HOME:?}/git/bcbio-nextgen"
        [output_dir]="${PWD:?}/bcbio-tests"
        [tools_dir]="$(koopa_bcbio_nextgen_tools_prefix)"
    )
    while (("$#"))
    do
        case "$1" in
            '--git-dir='*)
                dict[git_dir]="${1#*=}"
                shift 1
                ;;
            '--git-dir')
                dict[git_dir]="${2:?}"
                shift 2
                ;;
            '--output-dir='*)
                dict[output_dir]="${1#*=}"
                shift 1
                ;;
            '--output-dir')
                dict[output_dir]="${2:?}"
                shift 2
                ;;
            '--tools-dir='*)
                dict[tools_dir]="${1#*=}"
                shift 1
                ;;
            '--tools-dir')
                dict[tools_dir]="${2:?}"
                shift 2
                ;;
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_dir "${dict[git_dir]}" "${dict[tools_dir]}"
    koopa_mkdir "${dict[output_dir]}"
    (
        koopa_add_to_path_start "${dict[tools_dir]}/bin"
        koopa_cd "${dict[git_dir]}/tests"
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
            export BCBIO_TEST_DIR="${dict[output_dir]}/${test}"
            ./run_tests.sh "$test" --keep-test-dir
        done
    )
    koopa_alert_success "Unit tests passed for '${dict[tools_dir]}'."
    return 0
}
koopa_linux_bcl2fastq_indrops() {
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [bcl2fastq]="$(koopa_linux_locate_bcl2fastq)"
        [tee]="$(koopa_locate_tee)"
    )
    declare -A dict=(
        [log_file]='bcl2fastq-indrops.log'
    )
    "${app[bcl2fastq]}" \
        --use-bases-mask 'y*,y*,y*,y*' \
        --mask-short-adapter-reads 0 \
        --minimum-trimmed-read-length 0 \
        2>&1 | "${app[tee]}" "${dict[log_file]}"
    return 0
}
koopa_linux_configure_lmod() {
    local dict
    koopa_assert_has_args_le "$#" 1
    koopa_assert_is_admin
    declare -A dict=(
        [etc_dir]='/etc/profile.d'
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="$(koopa_lmod_prefix)"
    dict[init_dir]="${dict[prefix]}/apps/lmod/lmod/init"
    koopa_assert_is_dir "${dict[init_dir]}"
    if [[ ! -d "${dict[etc_dir]}" ]]
    then
        koopa_mkdir --sudo "${dict[etc_dir]}"
    fi
    koopa_ln --sudo \
        "${dict[init_dir]}/profile" \
        "${dict[etc_dir]}/z00_lmod.sh"
    koopa_ln --sudo \
        "${dict[init_dir]}/cshrc" \
        "${dict[etc_dir]}/z00_lmod.csh"
    if koopa_is_installed 'fish'
    then
        dict[fish_etc_dir]='/etc/fish/conf.d'
        koopa_alert "Updating Fish configuration in '${dict[fish_etc_dir]}'."
        if [[ ! -d "${dict[fish_etc_dir]}" ]]
        then
            koopa_mkdir --sudo "${dict[fish_etc_dir]}"
        fi
        koopa_ln --sudo \
            "${dict[init_dir]}/profile.fish" \
            "${dict[fish_etc_dir]}/z00_lmod.fish"
    fi
    return 0
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
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [file]='/etc/sudo.conf'
        [string]='Set disable_coredump false'
    )
    koopa_sudo_append_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
    return 0
}
koopa_linux_install_apptainer() {
    koopa_install_app \
        --name='apptainer' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_aspera_connect() {
    koopa_install_app \
        --link-in-bin='bin/ascp' \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_attr() {
    koopa_install_app \
        --installer='gnu-app' \
        --name='attr' \
        --platform='linux' \
       -D '--disable-debug' \
       -D '--disable-dependency-tracking' \
       -D '--disable-silent-rules' \
        "$@"
}
koopa_linux_install_aws_cli() {
    koopa_install_app \
        --link-in-bin='bin/aws' \
        --name-fancy='AWS CLI' \
        --name='aws-cli' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_bcbio_nextgen() {
    koopa_install_app \
        --link-in-bin='tools/bin/bcbio_nextgen.py' \
        --name='bcbio-nextgen' \
        --platform='linux' \
        --version="$(koopa_current_bcbio_nextgen_version)" \
        "$@"
}
koopa_linux_install_bcl2fastq() {
    if koopa_is_fedora
    then
        koopa_install_app \
            --link-in-bin='bin/bcl2fastq' \
            --installer='bcl2fastq-from-rpm' \
            --name='bcl2fastq' \
            --platform='fedora' \
            "$@"
    else
        koopa_install_app \
            --link-in-bin='bin/bcl2fastq' \
            --name='bcl2fastq' \
            --platform='linux' \
            "$@"
    fi
    return 0
}
koopa_linux_install_cellranger() {
    koopa_install_app \
        --link-in-bin='bin/cellranger' \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_cloudbiolinux() {
    koopa_install_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --platform='linux' \
        --version='latest' \
        "$@"
}
koopa_linux_install_docker_credential_pass() {
    koopa_install_app \
        --link-in-bin='bin/docker-credential-pass' \
        --name='docker-credential-pass' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_julia_binary() {
    koopa_install_app \
        --installer="julia-binary" \
        --link-in-bin='bin/julia' \
        --name-fancy='Julia' \
        --name='julia' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_lmod() {
    koopa_install_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
}
koopa_linux_install_pihole() {
    koopa_update_app \
        --name-fancy='Pi-hole' \
        --name='pihole' \
        --platform='linux' \
        --system \
        "$@"
}
koopa_linux_install_pivpn() {
    koopa_update_app \
        --name-fancy='PiVPN' \
        --name='pivpn' \
        --platform='linux' \
        --system \
        "$@"
}
koopa_linux_java_update_alternatives() {
    local app dict
    local prefix priority
    koopa_assert_has_args_eq "$#" 1
    koopa_assert_is_admin
    declare -A app=(
        [sudo]="$(koopa_locate_sudo)"
        [update_alternatives]="$(koopa_linux_locate_update_alternatives)"
    )
    declare -A dict=(
        [alt_prefix]='/var/lib/alternatives'
        [prefix]="$(koopa_realpath "${1:?}")"
        [priority]=100
    )
    koopa_rm --sudo \
        "${dict[alt_prefix]}/java" \
        "${dict[alt_prefix]}/javac" \
        "${dict[alt_prefix]}/jar"
    "${app[sudo]}" "${app[update_alternatives]}" --install \
        '/usr/bin/java' \
        'java' \
        "${dict[prefix]}/bin/java" \
        "${dict[priority]}"
    "${app[sudo]}" "${app[update_alternatives]}" --install \
        '/usr/bin/javac' \
        'javac' \
        "${dict[prefix]}/bin/javac" \
        "${dict[priority]}"
    "${app[sudo]}" "${app[update_alternatives]}" --install \
        '/usr/bin/jar' \
        'jar' \
        "${dict[prefix]}/bin/jar" \
        "${dict[priority]}"
    "${app[sudo]}" "${app[update_alternatives]}" --set \
        'java' \
        "${dict[prefix]}/bin/java"
    "${app[sudo]}" "${app[update_alternatives]}" --set \
        'javac' \
        "${dict[prefix]}/bin/javac"
    "${app[sudo]}" "${app[update_alternatives]}" --set \
        'jar' \
        "${dict[prefix]}/bin/jar"
    "${app[update_alternatives]}" --display 'java'
    "${app[update_alternatives]}" --display 'javac'
    "${app[update_alternatives]}" --display 'jar'
    return 0
}
koopa_linux_locate_bcbio() {
    koopa_locate_app 'bcbio-nextgen.py'
}
koopa_linux_locate_bcl2fastq() {
    koopa_locate_app 'bcl2fastq'
}
koopa_linux_locate_getconf() {
    koopa_locate_app '/usr/bin/getconf'
}
koopa_linux_locate_groupadd() {
    koopa_locate_app '/usr/sbin/groupadd'
}
koopa_linux_locate_gpasswd() {
    koopa_locate_app '/usr/bin/gpasswd'
}
koopa_linux_locate_ldconfig() {
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'alpine' | \
        'debian')
            str='/sbin/ldconfig'
            ;;
        *)
            str='/usr/sbin/ldconfig'
            ;;
    esac
    koopa_locate_app "$str"
}
koopa_linux_locate_systemctl() {
    local os_id str
    os_id="$(koopa_os_id)"
    case "$os_id" in
        'debian')
            str='/bin/systemctl'
            ;;
        *)
            str='/usr/bin/systemctl'
            ;;
    esac
    koopa_locate_app "$str"
}
koopa_linux_locate_update_alternatives() {
    local str
    if koopa_is_fedora_like
    then
        str='/usr/sbin/update-alternatives'
    else
        str='/usr/bin/update-alternatives'
    fi
    koopa_locate_app "$str"
}
koopa_linux_locate_useradd() {
    koopa_locate_app '/usr/sbin/useradd'
}
koopa_linux_locate_usermod() {
    koopa_locate_app '/usr/sbin/usermod'
}
koopa_linux_os_version() {
    local app x
    koopa_assert_has_no_args "$#"
    declare -A app=(
        [uname]="$(koopa_locate_uname)"
    )
    x="$("${app[uname]}" -r)"
    [[ -n "$x" ]] || return 1
    koopa_print "$x"
    return 0
}
koopa_linux_remove_user_from_group() {
    local app dict
    koopa_assert_has_args_le "$#" 2
    koopa_assert_is_admin
    declare -A app=(
        [gpasswd]="$(koopa_linux_locate_gpasswd)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [group]="${1:?}"
        [user]="${2:-}"
    )
    [[ -z "${dict[user]}" ]] && dict[user]="$(koopa_user)"
    "${app[sudo]}" "${app[gpasswd]}" --delete "${dict[user]}" "${dict[group]}"
    return 0
}
koopa_linux_uninstall_apptainer() {
    koopa_uninstall_app \
        --name='apptainer' \
        "$@"
}
koopa_linux_uninstall_aspera_connect() {
    koopa_uninstall_app \
        --name-fancy='Aspera Connect' \
        --name='aspera-connect' \
        --platform='linux' \
        --unlink-in-bin='ascp' \
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
        --unlink-in-bin='bcbio_nextgen.py' \
        "$@"
}
koopa_linux_uninstall_bcl2fastq() {
    koopa_uninstall_app \
        --name='bcl2fastq' \
        --platform='linux' \
        --unlink-in-bin='bcl2fastq' \
        "$@"
}
koopa_linux_uninstall_cellranger() {
    koopa_uninstall_app \
        --name-fancy='Cell Ranger' \
        --name='cellranger' \
        --platform='linux' \
        --unlink-in-bin='cellranger' \
        "$@"
}
koopa_linux_uninstall_cloudbiolinux() {
    koopa_uninstall_app \
        --name-fancy='CloudBioLinux' \
        --name='cloudbiolinux' \
        --platform='linux' \
        "$@"
}
koopa_linux_uninstall_docker_credential_pass() {
    koopa_uninstall_app \
        --name='docker-credential-pass' \
        --platform='linux' \
        --unlink-in-bin='docker-credential-pass' \
        "$@"
}
koopa_linux_uninstall_lmod() {
    koopa_uninstall_app \
        --name-fancy='Lmod' \
        --name='lmod' \
        --platform='linux' \
        "$@"
    return 0
}
koopa_linux_update_etc_profile_d() {
    local dict
    koopa_assert_has_no_args "$#"
    koopa_is_shared_install || return 0
    koopa_assert_is_admin
    declare -A dict=(
        [koopa_prefix]="$(koopa_koopa_prefix)"
        [file]='/etc/profile.d/zzz-koopa.sh'
    )
    if [[ -f "${dict[file]}" ]] && [[ ! -L "${dict[file]}" ]]
    then
        return 0
    fi
    koopa_alert "Adding koopa activation to '${dict[file]}'."
    koopa_rm --sudo "${dict[file]}"
    read -r -d '' "dict[string]" << END || true
__koopa_activate_shared_profile() {
    . "${dict[koopa_prefix]}/activate"
    return 0
}
__koopa_activate_shared_profile
END
    koopa_sudo_write_string \
        --file="${dict[file]}" \
        --string="${dict[string]}"
}
koopa_linux_update_ldconfig() {
    local app dict source_file
    koopa_assert_has_no_args "$#"
    koopa_assert_is_admin
    declare -A app=(
        [ldconfig]="$(koopa_linux_locate_ldconfig)"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [distro_prefix]="$(koopa_distro_prefix)"
        [target_prefix]='/etc/ld.so.conf.d'
    )
    [[ -d "${dict[target_prefix]}" ]] || return 0
    dict[conf_source]="${dict[distro_prefix]}${dict[target_prefix]}"
    [[ -d "${dict[conf_source]}" ]] || return 0
    koopa_alert "Updating ldconfig in '${dict[target_prefix]}'."
    for source_file in "${dict[conf_source]}/"*".conf"
    do
        local target_bn target_file
        target_bn="koopa-$(koopa_basename "$source_file")"
        target_file="${dict[target_prefix]}/${target_bn}"
        koopa_ln --sudo "$source_file" "$target_file"
    done
    "${app[sudo]}" "${app[ldconfig]}" || true
    return 0
}
koopa_linux_update_sshd_config() {
    local dict
    koopa_assert_has_no_args "$#"
    declare -A dict=(
        [source_file]="$(koopa_koopa_prefix)/os/linux/common/etc/ssh/\
sshd_config.d/koopa.conf"
        [target_file]='/etc/ssh/sshd_config.d/koopa.conf'
    )
    koopa_ln --sudo "${dict[source_file]}" "${dict[target_file]}"
    return 0
}
