#!/usr/bin/env bash

koopa::bcbio_run_tests() { # {{{1
    # """
    # Run bcbio unit tests.
    # @note Updated 2020-07-14.
    # """
    local bcbio_prefix bin_dir git_dir tests_dir version
    bcbio_prefix="$(koopa::bcbio_prefix)"
    version='development'
    while (("$#"))
    do
        case "$1" in
            --bcbio-prefix=*)
                bcbio_prefix="${1#*=}"
                shift 1
                ;;
            --bcbio-prefix)
                bcbio_prefix="$2"
                shift 2
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_is_dir "$bcbio_prefix"
    bin_dir="${bcbio_prefix}/${version}/tools/bin"
    koopa::assert_is_dir "$bin_dir"
    git_dir="${bcbio_prefix}/git"
    koopa::assert_is_dir "$git_dir"
    tests_dir="${git_dir}/tests"
    koopa::assert_is_dir "$tests_dir"
    (
        export PATH="${bin_dir}:${PATH}"
        koopa::cd "$tests_dir"
        koopa::rm test_automated_output
        ./run_tests.sh fastrnaseq
        ./run_tests.sh star
        ./run_tests.sh hisat2
        ./run_tests.sh rnaseq
        ./run_tests.sh stranded
        ./run_tests.sh chipseq
        ./run_tests.sh scrnaseq
        rm -frv test_automated_output
    )
    koopa::success 'All unit tests passed.'
    return 0
}

koopa::install_bcbio() { # {{{1
    local app_prefix current_version file install_dir name name_fancy prefix \
        python tmp_dir tools_dir url version
    name='bcbio'
    version='stable'
    app_prefix="$(koopa::app_prefix)/${name}"
    while (("$#"))
    do
        case "$1" in
            --prefix=*)
                prefix="${1#*=}"
                shift 1
                ;;
            --prefix)
                prefix="$2"
                shift 2
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    app_prefix="$(koopa::strip_trailing_slash "$app_prefix")"
    if [[ "$version" == 'stable' ]]
    then
        current_version="$(koopa::current_bcbio_version)"
        prefix="${app_prefix}/${current_version}"
    else
        prefix="${app_prefix}/${version}"
    fi
    koopa::exit_if_dir "$prefix"
    name_fancy='bcbio-nextgen'
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
            --upgrade="$version"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    # Clean up conda packages.
    # > conda_exe="${install_dir}/anaconda/bin/conda"
    # > conda_exe="${tools_dir}/bin/bcbio_conda"
    # > "$conda_exe" clean --yes --tarballs
    if [[ "$version" == 'stable' ]]
    then
        koopa::sys_ln "${app_prefix}/${current_version}" "${app_prefix}/stable"
    fi
    koopa::sys_set_permissions -r "$app_prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::install_bcbio_ensembl_genome() { # {{{1
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
            --build)
                build="$2"
                shift 2
                ;;
            --indexes=*)
                indexes="${1#*=}"
                shift 1
                ;;
            --indexes)
                indexes="$2"
                shift 2
                ;;
            --organism=*)
                organism="${1#*=}"
                shift 1
                ;;
            --organism)
                organism="$2"
                shift 2
                ;;
            --release=*)
                release="${1#*=}"
                shift 1
                ;;
            --release)
                release="$2"
                shift 2
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
        koopa::stop "Invalid organism: \"${organism}\"."
    fi
    # Sanitize spaces into underscores.
    # Use bash built-in rather than sed, when possible.
    organism="${organism// /_}"
    source='Ensembl'
    bcbio_genome_name="${build}-${source}-${release}"
    koopa::install_start "$bcbio_genome_name"
    # e.g. "Hsapiens".
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

koopa::install_bcbio_genome() { # {{{1
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

