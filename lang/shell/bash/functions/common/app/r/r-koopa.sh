#!/usr/bin/env bash

koopa::r_koopa() { # {{{1
    # """
    # Execute a function in koopa R package.
    # @note Updated 2021-10-29.
    # """
    local app code header_file fun pos rscript_args
    koopa::assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa::locate_rscript)"
    )
    rscript_args=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--vanilla')
                rscript_args+=('--vanilla')
                shift 1
                ;;
            '--'*)
                pos+=("$1")
                shift 1
                ;;
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    fun="${1:?}"
    shift 1
    header_file="$(koopa::koopa_prefix)/lang/r/include/header.R"
    koopa::assert_is_file "$header_file"
    code=("source('${header_file}');")
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    if [[ "$fun" != 'header' ]]
    then
        code+=("koopa::${fun}();")
    fi
    # Ensure positional arguments get properly quoted (escaped).
    pos=("$@")
    "${app[rscript]}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}

koopa::drat() { # {{{
    # """
    # Add R package to drat repository.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDrat' "$@"
}

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadEnsemblGenome' "$@"
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadGencodeGenome' "$@"
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadRefseqGenome' "$@"
}

koopa::download_ucsc_genome() { # {{{1
    # """
    # Download UCSC genome.
    # @note Updated 2021-08-18.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadUCSCGenome' "$@"
}

koopa::pkgdown_deploy_to_aws() { # {{{1
    # """
    # Deploy a pkgdown website to AWS.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliPkgdownDeployToAWS' "$@"
}
