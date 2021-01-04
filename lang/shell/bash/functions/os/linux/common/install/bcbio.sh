#!/usr/bin/env bash

# FIXME NEED A NEW FUNCTION HERE, SUCH AS KOOPA::ADD_OPT_LINK.
# FIXME RENAME OPT BACK HERE TO APP AND REWORK...

koopa::linux_install_bcbio() { # {{{1
    # """
    # Install bcbio-nextgen.
    # @note Updated 2020-11-19.
    # """
    local file install_dir name name_fancy prefix \
        python tmp_dir tools_dir url version
    name='bcbio'
    name_fancy='bcbio-nextgen'
    version="$(koopa::current_bcbio_version)"
    prefix="$(koopa::opt_prefix)/${name}/${version}"
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
    # FIXME NEED TO LINK THIS INTO OPT HERE.
    koopa::install_success "$name_fancy"
    return 0
}

# FIXME USE OPT PREFIX HERE...
koopa::linux_install_bcbio_ensembl_genome() { # {{{1
    # """
    # Install bcbio genome from Ensembl.
    # @note Updated 2020-08-13.
    # """
    local bcbio_genome_name bcbio_species_dir build cores fasta gtf indexes \
        organism release tmp_dir
    koopa::assert_has_args "$#"
    koopa::assert_is_installed awk bcbio_setup_genome.py \
        download-ensembl-genome du find head sort xargs
    while (("$#"))
    do
        case "$1" in
            --build=*)
                build="${1#*=}"
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
    koopa::assert_is_set build organism release
    [[ -z "${indexes:-}" ]] && indexes='bowtie2 seq star'
    # Convert string to array.
    indexes=("$indexes")
    # Check for valid organism input.
    if ! koopa::str_match_regex "$organism" '^([A-Z][a-z]+)(\s|_)([a-z]+)$'
    then
        koopa::stop "Invalid organism: '${organism}'."
    fi
    # Sanitize spaces into underscores.
    # Use bash built-in rather than sed, when possible.
    organism="${organism// /_}"
    source='Ensembl'
    bcbio_genome_name="${build}-${source}-${release}"
    koopa::install_start "$bcbio_genome_name"
    # e.g. 'Hsapiens'.
    bcbio_species_dir="$( \
        koopa::print "$organism" \
            | sed -r 's/^([A-Z]).+_([a-z]+)$/\1\2/g' \
    )"
    tmp_dir="$(koopa::tmp_dir)"
    cores="$(koopa::cpu_count)"
    (
        koopa::cd "$tmp_dir"
        download-ensembl-genome \
            --organism "$organism" \
            --build "$build" \
            --release "$release" \
            --type 'genome' \
            --annotation 'gtf' \
            --decompress
        # Automatically locate the largest FASTA and GTF files.
        # e.g. homo-sapiens-grch38-ensembl-100/genome/
        #          Homo_sapiens.GRCh38.dna.primary_assembly.fa
        fasta="$(\
            find '.' \
                -mindepth 3 \
                -maxdepth 3 \
                -name '*.fa' \
                -print0 \
            | xargs -0 du -sk \
            | sort -nr  \
            | head -n 1 \
            | awk '{print $2}' \
        )"
        koopa::assert_is_file "$fasta"
        fasta="$(realpath "$fasta")"
        # e.g. homo-sapiens-grch38-ensembl-100/gtf/
        #          Homo_sapiens.GRCh38.100.chr_patch_hapl_scaff.gtf
        gtf="$( \
            find . \
                -mindepth 3 \
                -maxdepth 3 \
                -name '*.gtf' \
                -type f \
                -print0 \
            | xargs -0 du -sk \
            | sort -nr  \
            | head -n 1 \
            | awk '{print $2}' \
        )"
        koopa::assert_is_file "$gtf"
        gtf="$(realpath "$gtf")"
        koopa::dl 'FASTA' "$(basename "$fasta")"
        koopa::dl 'GTF' "$(basename "$gtf")"
        koopa::dl 'Indexes' "${indexes[*]}"
        bcbio_setup_genome.py \
            --name "$bcbio_species_dir" \
            --build "$bcbio_genome_name" \
            --cores "$cores" \
            --fasta "$fasta" \
            --gtf "$gtf" \
            --indexes "${indexes[@]}"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$bcbio_genome_name"
    return 0
}

koopa::linux_install_bcbio_genome() { # {{{1
    local bcbio bcbio_dir cores flags genomes genomes_dir name_fancy tmp_dir
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    koopa::assert_is_installed bcbio_nextgen.py
    bcbio="$(koopa::which_realpath bcbio_nextgen.py)"
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

# FIXME RETHINK THIS ALSO, FOLLOWING BCBIO CHANGE ABOVE.
koopa::linux_install_bcbio_vm() { # {{{1
    # """
    # Install bcbio-vm.
    # @note Updated 2020-11-19.
    # """
    local bin_dir data_dir file name prefix tmp_dir url
    koopa::assert_has_no_envs
    koopa::assert_is_installed docker
    name='bcbio-vm'
    prefix="$(koopa::opt_prefix)/${name}"
    [[ -d "$prefix" ]] && return 0
    koopa::install_start "$name" "$prefix"
    bin_dir="${prefix}/anaconda/bin"
    tmp_dir="$(koopa::tmp_dir)"
    # Configure Docker, if necessary.
    if ! koopa::str_match "$(groups)" 'docker'
    then
        sudo groupadd docker
        sudo service docker restart
        sudo gpasswd -a "$(whoami)" docker
        newgrp docker
    fi
    # Download and install Conda.
    (
        koopa::cd "$tmp_dir"
        file='Miniconda3-latest-Linux-x86_64.sh'
        url="https://repo.continuum.io/miniconda/${file}"
        koopa::download "$url"
        bash "$file" -b -p "${prefix}/anaconda"
    )
    koopa::rm "$tmp_dir"
    # Ready to install bcbio-vm.
    "${bin_dir}/conda" install --yes \
        --channel='conda-forge' \
        --channel='bioconda' \
        bcbio-nextgen \
        bcbio-nextgen-vm
    koopa::ln -S "${bin_dir}/bcbio_vm.py" '/usr/local/bin/bcbio_vm.py'
    koopa::ln -S "${bin_dir}/conda" '/usr/local/bin/bcbiovm_conda'
    sudo chgrp docker '/usr/local/bin/bcbio_vm.py'
    sudo chmod g+s '/usr/local/bin/bcbio_vm.py'
    # v1.1.3:
    # > data_dir="${prefix}/v1.1.3"
    # > image='quay.io/bcbio/bcbio-vc:1.1.3-v1.1.3'
    # latest version:
    data_dir="${prefix}/latest"
    # > image='quay.io/bcbio/bcbio-vc'
    "${bin_dir}/bcbio_vm.py" --datadir="$data_dir" saveconfig
    # > "${bin_dir}/bcbio_vm.py" install --tools --image "$image"
    koopa::install_success "$name"
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
