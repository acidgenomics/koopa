#!/usr/bin/env bash

# FIXME Consider renaming 'koopa::r_script' to 'koopa::r_script'.

koopa::array_to_r_vector() { # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2020-07-20.
    # """
    local x
    koopa::assert_has_args "$#"
    x="$(printf '"%s", ' "$@")"
    x="$(koopa::strip_right ', ' "$x")"
    x="$(printf 'c(%s)\n' "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::drat() { # {{{
    # """
    # Add R package to drat repository.
    # @note Updated 2020-12-07.
    # """
    koopa::r_script 'drat' "$@"
    return 0
}

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::r_script 'downloadEnsemblGenome' "$@"
    return 0
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::r_script 'downloadGencodeGenome' "$@"
    return 0
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::r_script 'downloadRefseqGenome' "$@"
    return 0
}

koopa::kill_r() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed 'pkill'
    pkill rsession
}

koopa::pkgdown_deploy_to_aws() { # {{{1
    # """
    # Deploy a pkgdown website to AWS.
    # @note Updated 2021-03-01.
    # """
    koopa::assert_has_args "$#"
    koopa::r_script 'pkgdownDeployToAWS' "$@"
    return 0
}

koopa::r_script() { # {{{1
    # """
    # Execute an R script.
    # @note Updated 2021-04-30.
    # """
    local code header_file flags fun pos r rscript
    r="$(koopa::locate_r)"
    rscript="${r}script"
    koopa::assert_is_installed "$rscript"
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            --vanilla)
                flags+=('--vanilla')
                shift 1
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
    code="source('${header_file}')"
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    if [[ "$fun" != 'header' ]]
    then
        code="${code}; koopa::${fun}()"
    fi
    # Ensure positional arguments get properly quoted (escaped).
    pos=("$@")
    "$rscript" "${flags[@]}" -e "$code" "${pos[@]@Q}"
    return 0
}

koopa::r_script_vanilla() { # {{{1
    # """
    # Run Rscript without configuration (vanilla mode).
    # @note Updated 2020-11-19.
    # """
    koopa::r_script --vanilla "$@"
    return 0
}

koopa::run_shiny_app() { # {{{1
    # """
    # Run Shiny application.
    # @note Updated 2021-04-29.
    # """
    local dir r
    dir="${1:-.}"
    r="$(koopa::locate_r)"
    koopa::assert_is_installed "$r"
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    "$r" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dir}')"
    return 0
}
