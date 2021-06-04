#!/usr/bin/env bash

koopa::linux_install_bcbio() { # {{{1
    local version
    version="$(koopa::current_bcbio_version)"
    koopa::install_app \
        --name='bcbio' \
        --name-fancy='bcbio-nextgen' \
        --no-link \
        --platform='linux' \
        --version="$version" \
        "$@"
}

koopa:::linux_install_bcbio() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2021-05-23.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    # """
    local conda file install_dir prefix python tools_dir upgrade url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    python="$(koopa::locate_python)"
    koopa::assert_is_installed "$python"
    koopa::alert_coffee_time
    install_dir="${prefix}/install"
    tools_dir="${prefix}/tools"
    case "$version" in
        development)
            upgrade='development'
            ;;
        *)
            upgrade='stable'
            ;;
    esac
    file='bcbio_nextgen_install.py'
    url="https://raw.github.com/bcbio/bcbio-nextgen/master/scripts/${file}"
    koopa::download "$url"
    koopa::mkdir "$prefix"
    "$python" \
        "$file" \
        "$install_dir" \
        --datatarget='rnaseq' \
        --datatarget='variation' \
        --isolate \
        --nodata \
        --tooldir="$tools_dir" \
        --upgrade="$upgrade"
    # Clean up conda packages inside Docker image.
    if koopa::is_docker
    then
        # > conda="${install_dir}/anaconda/bin/conda"
        conda="${tools_dir}/bin/bcbio_conda"
        koopa::assert_is_file "$conda"
        "$conda" clean --yes --tarballs
    fi
    return 0
}

koopa::linux_install_bcbio_ensembl_genome() { # {{{1
    # """
    # Install bcbio genome from Ensembl.
    # @note Updated 2021-05-26.
    #
    # This script can fail on a clean bcbio install if this file is missing:
    # 'install/galaxy/tool-data/sam_fa_indices.loc'.
    #
    # @section Genome download:
    #
    # Use the 'download-ensembl-genome' script to simplify this step.
    # This script prepares top-level standardized files named 'genome.fa.gz'
    # (FASTA) and 'annotation.gtf.gz' (GTF) that we can pass to bcbio script.
    #
    # @examples
    # Ensure bcbio is in PATH.
    # export PATH="/opt/koopa/opt/bcbio-nextgen/tools/bin:${PATH}"
    # organism='Homo sapiens'
    # build='GRCh38'
    # release='102'
    # download-ensembl-genome \
    #     --organism="$organism" \
    #     --build="$build" \
    #     --release="$release"
    # genome_dir='homo-sapiens-grch38-ensembl-102'
    # # bcbio expects the genome FASTA, not the transcriptome.
    # fasta="${genome_dir}/genome/
    #     Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz"
    # # GTF is easier to parse than GFF3.
    # gtf="${genome_dir}/annotation/gtf/Homo_sapiens.GRCh38.102.gtf.gz"
    # # Now we're ready to call the install script.
    # koopa install bcbio-ensembl-genome \
    #     --build="$build" \
    #     --fasta="$fasta" \
    #     --gtf="$gtf" \
    #     --indexes="bowtie2 seq star" \
    #     --organism="$organism" \
    #     --release="$release"
    # """
    local bcbio_genome_name bcbio_species_dir build cores fasta gtf indexes
    local install_prefix organism provider release script sed tee tmp_dir
    local tool_data_prefix
    koopa::assert_has_args "$#"
    script='bcbio_setup_genome.py'
    koopa::assert_is_installed "$script"
    sed="$(koopa::locate_sed)"
    tee="$(koopa::locate_tee)"
    while (("$#"))
    do
        case "$1" in
            --build=*)
                build="${1#*=}"
                shift 1
                ;;
            --fasta=*)
                fasta="${1#*=}"
                shift 1
                ;;
            --gtf=*)
                gtf="${1#*=}"
                shift 1
                ;;
            --indexes=*)
                indexes="${1#*=}"
                shift 1
                ;;
            --organism=*)
                organism="${1#*=}"
                shift 1
                ;;
            --release=*)
                release="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    [[ -z "${indexes:-}" ]] && indexes='bowtie2 seq star'
    koopa::assert_is_set 'build' 'fasta' 'gtf' 'indexes' 'organism' 'release'
    koopa::assert_is_file "$fasta" "$gtf"
    script="$(koopa::which_realpath "$script")"
    fasta="$(koopa::realpath "$fasta")"
    gtf="$(koopa::realpath "$gtf")"
    # Convert space-delimited string to array.
    IFS=" " read -r -a indexes <<< "$indexes"
    # Check for valid organism input.
    if ! koopa::str_match_regex "$organism" '^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    then
        koopa::stop "Invalid organism: '${organism}'."
    fi
    provider='Ensembl'
    # e.g. "GRCh38_Ensembl_102".
    bcbio_genome_name="${build} ${provider} ${release}"
    bcbio_genome_name="${bcbio_genome_name// /_}"
    koopa::install_start "$bcbio_genome_name"
    # e.g. 'Hsapiens'.
    bcbio_species_dir="$( \
        koopa::print "${organism// /_}" \
            | "$sed" -r 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    tmp_dir="$(koopa::tmp_dir)"
    cores="$(koopa::cpu_count)"
    # Ensure Galaxy is configured correctly for a clean bcbio install.
    # Recursive up from 'install/anaconda/bin/bcbio_setup_genome.py'.
    install_prefix="$(koopa::parent_dir -n 3 "$script")"
    # If the 'sam_fa_indices.loc' file is missing, the script will error.
    tool_data_prefix="${install_prefix}/galaxy/tool-data"
    koopa::mkdir "$tool_data_prefix"
    touch "${tool_data_prefix}/sam_fa_indices.log"
    (
        # This step will download cloudbiolinux, so migrating to a temporary
        # directory is helpful, to avoid clutter.
        set -x
        koopa::cd "$tmp_dir"
        koopa::dl 'FASTA file' "$fasta"
        koopa::dl 'GTF file' "$gtf"
        koopa::dl 'Indexes' "${indexes[*]}"
        # Note that '--buildversion' was added in 2021 and is now required.
        "$script" \
            --build "$bcbio_genome_name" \
            --buildversion "${provider}_${release}" \
            --cores "$cores" \
            --fasta "$fasta" \
            --gtf "$gtf" \
            --indexes "${indexes[@]}" \
            --name "$bcbio_species_dir"
        set +x
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$bcbio_genome_name"
    return 0
}

koopa::linux_install_bcbio_genome() { # {{{1
    # """
    # Install a natively supported bcbio genome (e.g. hg38).
    # @note Updated 2021-05-26.
    # """
    local bcbio bcbio_dir cores flags genomes genomes_dir name_fancy tee tmp_dir
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    bcbio='bcbio_nextgen.py'
    koopa::assert_is_installed "$bcbio"
    bcbio="$(koopa::which_realpath "$bcbio")"
    bcbio_dir="$(cd "$(dirname "$bcbio")/../.." && pwd -P)"
    genomes=("$@")
    genomes_dir="${bcbio_dir}/genomes"
    name_fancy='bcbio-nextgen genomes'
    koopa::install_start "$name_fancy" "$genomes_dir"
    koopa::dl 'Genomes' "$(koopa::to_string "${genomes[@]}")"
    cores="$(koopa::cpu_count)"
    tee="$(koopa::locate_tee)"
    tmp_dir="$(koopa::tmp_dir)"
    flags=(
        "--cores=${cores}"
        '--upgrade=skip'
    )
    for genome in "${genomes[@]}"
    do
        flags+=("--genomes=${genome}")
    done
    koopa::dl 'Flags' "${flags[@]}"
    (
        koopa::cd "$tmp_dir"
        "$bcbio" upgrade "${flags[@]}"
    ) 2>&1 | "$tee" "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

# NOTE ARM is not yet support for this.
koopa::linux_install_bcbio_vm() { # {{{1
    # """
    # Install bcbio-vm.
    # @note Updated 2021-05-20.
    # """
    local bin_dir conda file make_bin_dir make_prefix name name_fancy prefix url
    koopa::assert_has_no_envs
    koopa::assert_is_installed 'conda' 'docker'
    name='bcbio-vm'
    name_fancy='bcbio-nextgen-vm'
    version="$(koopa::conda_env_latest_version "$name")"
    prefix="$(koopa::app_prefix)/${version}/${name}"
    if [[ -d "$prefix" ]]
    then
        koopa::alert_note "'${name_fancy}' already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$prefix"
    # Configure Docker, if necessary.
    if ! koopa::str_match "$(groups)" 'docker'
    then
        sudo groupadd 'docker'
        sudo service docker restart
        sudo gpasswd -a "$(whoami)" 'docker'
        newgrp 'docker'
    fi
    # Download and install Conda.
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='Miniconda3-latest-Linux-x86_64.sh'
        url="https://repo.continuum.io/miniconda/${file}"
        koopa::download "$url"
        bash "$file" -b -p "${prefix}/anaconda"
    )
    koopa::rm "$tmp_dir"
    # Ready to install bcbio-vm.
    bin_dir="${prefix}/anaconda/bin"
    conda="${bin_dir}/conda"
    "$conda" install --yes \
        --channel='conda-forge' \
        --channel='bioconda' \
        'bcbio-nextgen' \
        'bcbio-nextgen-vm'
    # Symlink into '/usr/local'.
    make_prefix="$(koopa::make_prefix)"
    make_bin_dir="${make_prefix}/bin"
    koopa::ln -S "${bin_dir}/bcbio_vm.py" "${make_bin_dir}/bcbio_vm.py"
    koopa::chgrp -S docker "${make_bin_dir}/bcbio_vm.py"
    koopa::chmod -S g+s "${make_bin_dir}/bcbio_vm.py"
    # Install pinned bcbio-nextgen v1.2.4:
    # > data_dir="${prefix}/v1.2.4"
    # > image='quay.io/bcbio/bcbio-vc:1.2.4-517bb34'
    # Install latest version of bcbio-nextgen:
    # > data_dir="${prefix}/latest"
    # > image='quay.io/bcbio/bcbio-vc:latest'
    # > "${bin_dir}/bcbio_vm.py" --datadir="$data_dir" saveconfig
    # > "${bin_dir}/bcbio_vm.py" install --tools --image "$image"
    koopa::link_into_opt "$prefix" "$name"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::linux_patch_bcbio() { # {{{1
    # """
    # Patch bcbio.
    # @note Updated 2021-05-20.
    # """
    local bcbio_python cache_files git_dir install_dir name_fancy
    # FIXME Locate tee here instead...
    koopa::assert_is_installed 'tee'
    koopa::assert_has_no_envs
    name_fancy='bcbio-nextgen'
    while (("$#"))
    do
        case "$1" in
            --bcbio-python=*)
                bcbio_python="${1#*=}"
                shift 1
                ;;
            --git-dir=*)
                git_dir="${1#*=}"
                shift 1
                ;;
            --install-dir=*)
                install_dir="${1#*=}"
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    # Locate bcbio git directory.
    if [[ -z "${git_dir:-}" ]]
    then
        git_dir="${HOME}/git/bcbio-nextgen"
    fi
    koopa::assert_is_dir "$git_dir"
    # Locate bcbio python.
    if [[ -z "${bcbio_python:-}" ]]
    then
        bcbio_python="$(koopa::which_realpath 'bcbio_python')"
    fi
    koopa::assert_is_executable "$bcbio_python"
    # Locate bcbio installation directory.
    if [[ -z "${install_dir:-}" ]]
    then
        install_dir="$(koopa::cd "$(dirname "$bcbio_python")/../.." && pwd -P)"
    fi
    koopa::assert_is_dir "$install_dir"
    koopa::h1 "Patching ${name_fancy} installation."
    koopa::dl 'git_dir' "$git_dir"
    koopa::dl 'bcbio_python' "$bcbio_python"
    koopa::dl 'install_dir' "$install_dir"
    koopa::alert 'Removing Python cache and compiled pyc files in Git repo.'
    readarray -t cache_files <<< "$( \
        koopa::find \
            --glob='*.pyc' \
            --prefix="$git_dir" \
            --type='f'
    )"
    koopa::rm "${cache_files[@]}"
    readarray -t cache_files <<< "$( \
        koopa::find \
            --glob='__pycache__' \
            --prefix="$git_dir" \
            --type='d'
    )"
    koopa::rm "${cache_files[@]}"
    koopa::h2 "Removing Python installer cruft inside 'anaconda/lib/'."
    koopa::rm "${install_dir}/anaconda/lib/python"*'/site-packages/bcbio'*
    # Install command must be run relative to our forked git repo.
    # Note the use of absolute path to bcbio_python here.
    (
        koopa::cd "$git_dir"
        koopa::rm 'tests/test_automated_output'
        koopa::alert "Patching installation via 'setup.py' script."
        "$bcbio_python" setup.py install
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::alert_success "Patching of ${name_fancy} was successful."
    return 0
}

koopa::linux_update_bcbio() { # {{{1
    local bcbio cores name_fancy
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    bcbio='bcbio_nextgen.py'
    koopa::assert_is_installed "$bcbio"
    name_fancy='bcbio-nextgen'
    koopa::update_start "$name_fancy"
    koopa::dl "$bcbio" "$(koopa::which_realpath "$bcbio")"
    cores="$(koopa::cpu_count)"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        "$bcbio" upgrade \
            --cores="$cores" \
            --data \
            --tools \
            --upgrade='stable'
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::update_success "$name_fancy"
    return 0
}
