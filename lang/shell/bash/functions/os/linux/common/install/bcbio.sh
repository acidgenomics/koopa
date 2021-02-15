#!/usr/bin/env bash

koopa::linux_install_bcbio() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2021-02-15.
    #
    # Consider just installing RNA-seq and not variant calling by default,
    # to speed up the installation.
    # """
    local file install_dir name name_fancy prefix \
        python tmp_dir tools_dir url version
    name='bcbio-nextgen'
    name_fancy="$name"
    version="$(koopa::current_bcbio_version)"
    prefix="$(koopa::app_prefix)/${name}/${version}"
    if [[ -d "$prefix" ]]
    then
        koopa::note "${name_fancy} already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::coffee_time
    koopa::assert_has_no_envs
    python="$(koopa::python)"
    koopa::mkdir "$prefix"
    install_dir="${prefix}/install"
    tools_dir="${prefix}/tools"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        file='bcbio_nextgen_install.py'
        url="https://raw.github.com/bcbio/bcbio-nextgen/master/scripts/${file}"
        koopa::download "$url"
        "$python" \
            "$file" \
            "$install_dir" \
            --datatarget='rnaseq' \
            --datatarget='variation' \
            --isolate \
            --nodata \
            --tooldir="$tools_dir" \
            --upgrade='stable'
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    # Clean up conda packages inside Docker image.
    if koopa::is_docker
    then
        # > conda="${install_dir}/anaconda/bin/conda"
        conda="${tools_dir}/bin/bcbio_conda"
        koopa::assert_is_file "$conda"
        "$conda" clean --yes --tarballs
    fi
    koopa::sys_set_permissions -r "$prefix"
    koopa::link_into_opt "$prefix" "$name"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::linux_install_bcbio_ensembl_genome() { # {{{1
    # """
    # Install bcbio genome from Ensembl.
    # @note Updated 2021-02-15.
    #
    # This script can fail on a clean bcbio install if this file is missing:
    # 'install/galaxy/tool-data/sam_fa_indices.loc'.
    #
    # @section Genome download:
    #
    # Use the 'download-ensembl-genome' script to simplify this step.
    # This script prepares top-level standardized files named "genome.fa.gz"
    # (FASTA) and "annotation.gtf.gz" (GTF) that we can pass to bcbio script.
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
    local bcbio_genome_name bcbio_prefix bcbio_species_dir build cores fasta \
        gtf indexes organism provider release script tmp_dir
    koopa::assert_has_args "$#"
    script='bcbio_setup_genome.py'
    koopa::assert_is_installed "$script" \
        'awk' 'du' 'find' 'head' 'sort' 'xargs'
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
    koopa::assert_is_set build fasta gtf indexes organism release
    koopa::assert_is_file "$fasta" "$gtf"
    script="$(koopa::which_realpath "$script")"
    echo "$script"

    bcbio_prefix="$(koopa::parent_dir -n 3 "$script")"
    echo "$bcbio_prefix"
    return 0
    # FIXME NEED TO ENSURE GALAXY IS STRUCTURED CORRECTLY.
    ## koopa::mkdir install/galaxy/tool-data
    ## touch install/galaxy/tool-data/sam_fa_indices.loc

    fasta="$(realpath "$fasta")"
    gtf="$(realpath "$gtf")"
    # Convert space-delimited string to array.
    IFS=" " read -r -a indexes <<< "$indexes"
    # Check for valid organism input.
    if ! koopa::str_match_regex "$organism" '^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    then
        koopa::stop "Invalid organism: '${organism}'."
    fi
    provider='Ensembl'
    bcbio_genome_name="${build} ${provider} ${release}"
    bcbio_genome_name="${bcbio_genome_name// /_}"
    koopa::install_start "$bcbio_genome_name"
    # e.g. 'Hsapiens'.
    bcbio_species_dir="$( \
        koopa::print "${organism// /_}" \
            | sed -r 's/^([A-Z])[a-z]+_([a-z]+)$/\1\2/g' \
    )"
    tmp_dir="$(koopa::tmp_dir)"
    cores="$(koopa::cpu_count)"
    (
        set -x
        koopa::cd "$tmp_dir"
        koopa::dl 'FASTA file' "$fasta"
        koopa::dl 'GTF file' "$gtf"
        koopa::dl 'Indexes' "${indexes[*]}"
        "$script" \
            --build "$build" \
            --buildversion "${provider}_${release}" \
            --cores "$cores" \
            --fasta "$fasta" \
            --gtf "$gtf" \
            --indexes "${indexes[@]}" \
            --name "$bcbio_species_dir"
        set +x
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$bcbio_genome_name"
    return 0
}

koopa::linux_install_bcbio_genome() { # {{{1
    # """
    # Install a natively supported bcbio genome (e.g. hg38).
    # @note Updated 2021-02-15.
    # """
    local bcbio bcbio_dir cores flags genomes genomes_dir name_fancy tmp_dir
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
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::linux_install_bcbio_vm() { # {{{1
    # """
    # Install bcbio-vm.
    # @note Updated 2021-01-20.
    # """
    local bin_dir conda file make_bin_dir make_prefix name name_fancy prefix url
    koopa::assert_has_no_envs
    koopa::assert_is_installed conda docker
    name='bcbio-nextgen-vm'
    name_fancy="$name_fancy"
    version="$(koopa::conda_env_latest_version "$name")"
    prefix="$(koopa::app_prefix)/${version}/${name}"
    if [[ -d "$prefix" ]]
    then
        koopa::note "'${name_fancy}' already installed at '${prefix}'."
        return 0
    fi
    koopa::install_start "$name_fancy" "$prefix"
    # Configure Docker, if necessary.
    if ! koopa::str_match "$(groups)" 'docker'
    then
        sudo groupadd docker
        sudo service docker restart
        sudo gpasswd -a "$(whoami)" docker
        newgrp docker
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
    sudo chgrp docker "${make_bin_dir}/bcbio_vm.py"
    sudo chmod g+s "${make_bin_dir}/bcbio_vm.py"
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
