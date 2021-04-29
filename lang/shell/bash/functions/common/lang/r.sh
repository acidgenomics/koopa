#!/usr/bin/env bash

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

koopa::configure_r() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2021-04-29.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    local etc_prefix make_prefix pkg_index r r_prefix
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    r="$(koopa::which_realpath "$r")"
    koopa::assert_is_installed "$r"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::h1 'Updating R configuration.'
    koopa::dl \
        'R home' "$r_prefix" \
        'R path' "$r"
    if koopa::is_symlinked_app "$r"
    then
        make_prefix="$(koopa::make_prefix)"
        etc_prefix="${make_prefix}/lib/R/etc"
        koopa::sys_set_permissions -r "$r_prefix"
        # Ensure that (Debian) system 'etc' directories are removed.
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            koopa::sys_rm "$etc_prefix"
        fi
        etc_prefix="${make_prefix}/lib64/R/etc"
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            koopa::sys_rm "$etc_prefix"
        fi
    else
        koopa::sys_set_permissions -r "${r_prefix}/library"
    fi
    koopa::link_r_etc "$r"
    koopa::link_r_site_library "$r"
    koopa::r_javareconf "$r"
    koopa::r_rebuild_docs "$r"
    # Skip this, to keep our Bioconductor Docker images light.
    # > koopa::install_r_koopa
    koopa::alert_success 'Update of R configuration was successful.'
    return 0
}

# NOTE This step currently doesn't work because custom drat repos (e.g. our
# Acid Genomics repo) are not currently supported on shinyapps.io.
# GitHub packages are supported.
koopa::deploy_shiny_app() { # {{{
    # """
    # Deploy a Shiny app to shinyapps.io
    # @note Updated 2021-04-08.
    # """
    local app_dir
    app_dir="${1:-.}"
    koopa::assert_is_installed R
    koopa::assert_is_dir "$app_dir"
    app_dir="$(koopa::realpath "$app_dir")"
    app_name="$(koopa::basename "$app_dir")"
    app_name="$(koopa::sub 'r-shiny' '' "$app_name")"
    koopa::h1 "Deploying '${app_name}' from '${app_dir}'."
    R \
        --no-restore \
        --no-save \
        --quiet \
        -e " \
            options(repos = append( \
                x = BiocManager::repositories(), \
                values = c('AcidGenomics' = 'https://r.acidgenomics.com') \
            )); \
            print(getOption('repos')); \
            rsconnect::deployApp( \
                appDir = '${app_dir}', \
                appName = '${app_name}' \
            ) \
        "
    return 0
}

koopa::drat() { # {{{
    # """
    # Add R package to drat repository.
    # @note Updated 2020-12-07.
    # """
    koopa::rscript 'drat' "$@"
    return 0
}

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadEnsemblGenome' "$@"
    return 0
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadGencodeGenome' "$@"
    return 0
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-01-04.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'downloadRefseqGenome' "$@"
    return 0
}

koopa::kill_r() { # {{{1
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed pkill
    pkill rsession
}

koopa::link_r_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2020-11-12.
    #
    # Don't copy Makevars file across machines.
    # """
    local distro_prefix file files r r_etc_source r_etc_target r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    koopa::is_installed "$r" || return 1
    r_prefix="$(koopa::r_prefix "$r")"
    [[ -d "$r_prefix" ]] || return 1
    version="$(koopa::r_version "$r")"
    if [[ "$version" != 'devel' ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    distro_prefix="$(koopa::distro_prefix)"
    r_etc_source="${distro_prefix}/etc/R/${version}"
    if [[ ! -d "$r_etc_source" ]]
    then
        koopa::warning "Missing R etc source: '${r_etc_source}'."
        return 1
    fi
    if koopa::is_linux && \
        ! koopa::is_symlinked_app "$r" && \
        [[ -d '/etc/R' ]]
    then
        # This applies to Debian/Ubuntu CRAN binary installs.
        r_etc_target='/etc/R'
    else
        r_etc_target="${r_prefix}/etc"
    fi
    files=(
        'Makevars.site'  # macOS
        'Renviron.site'
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        [[ -f "${r_etc_source}/${file}" ]] || continue
        koopa::sys_ln "${r_etc_source}/${file}" "${r_etc_target}/${file}"
    done
    return 0
}

# FIXME REWORK THE PATH HERE.
# FIXME CONSIDER LINKING TO '/opt/koopa/opt/r-packages'
koopa::link_r_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2020-11-23.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local lib_source lib_target opt_prefix r r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    opt_prefix="$(koopa::opt_prefix)"
    # > version="$(koopa::r_version "$r")"
    # > if [[ "$version" != 'devel' ]]
    # > then
    # >     version="$(koopa::major_minor_version "$version")"
    # > fi
    # > lib_source="${opt_prefix}/r/${version}/site-library"
    # FIXME NEED TO RETHINK THIS PATH.
    lib_source="${opt_prefix}/r/site-library"
    lib_target="${r_prefix}/site-library"
    koopa::dl 'Site library' "$lib_source"
    koopa::sys_mkdir "$lib_source"
    koopa::alert "Linking '${lib_source}' into R install at '${lib_target}'."
    koopa::sys_ln "$lib_source" "$lib_target"
    if koopa::is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa::alert_note 'Fixing Fedora R configuration.'
        koopa::sys_ln \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa::pkgdown_deploy_to_aws() { # {{{1
    # """
    # Deploy a pkgdown website to AWS.
    # @note Updated 2021-03-01.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'pkgdownDeployToAWS' "$@"
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2020-11-23.
    #
    # The default Java path differs depending on the system.
    #
    # > R CMD javareconf -h
    #
    # Environment variables that can be used to influence the detection:
    #   JAVA           path to a Java interpreter executable
    #                  By default first 'java' command found on the PATH
    #                  is taken (unless JAVA_HOME is also specified).
    #   JAVA_HOME      home of the Java environment. If not specified,
    #                  it will be detected automatically from the Java
    #                  interpreter.
    #   JAVAC          path to a Java compiler
    #   JAVAH          path to a Java header/stub generator
    #   JAR            path to a Java archive tool
    #
    # How to check that rJava works:
    # > library(rJava)
    # > .jinit()
    # """
    local java_flags java_home pos r r2
    pos=()
    while (("$#"))
    do
        case "$1" in
            --java-home=*)
                java_home="${1#*=}"
                shift 1
                ;;
            --r=*)
                r="${1#*=}"
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args_le "$#" 1
    [[ -n "${1:-}" ]] && r="$1"
    koopa::is_installed "$r" || return 0
    r="$(koopa::which_realpath "$r")"
    if [[ -z "${java_home:-}" ]]
    then
        koopa::activate_openjdk
        java_home="$(koopa::java_prefix)"
        koopa::is_installed java || return 0
    fi
    # This step can happen with r-devel in Docker images.
    if [[ ! -d "$java_home" ]]
    then
        koopa::alert_note "Failed to locate 'JAVA_HOME'."
        return 0
    fi
    koopa::alert 'Updating R Java configuration.'
    koopa::dl 'R' "$r"
    koopa::dl 'Java home' "$java_home"
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    if koopa::is_symlinked_app "$r"
    then
        r2=("$r")
    else
        koopa::assert_has_sudo
        r2=('sudo' "$r")
    fi
    "${r2[@]}" --vanilla CMD javareconf "${java_flags[@]}"
    return 0
}

koopa::r_rebuild_docs() { # {{{1
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2020-08-11.
    #
    # 1. Ensure HTML package index is writable.
    # 2. Touch an empty 'R.css' file to eliminate additional package warnings.
    #    Currently we're seeing this inside Fedora Docker images.
    #
    # @seealso
    # HTML package index configuration:
    # https://stat.ethz.ch/R-manual/R-devel/library/utils/html/
    #     make.packages.html.html
    # """
    local doc_dir html_dir pkg_index r rscript rscript_flags
    r="${1:-R}"
    rscript="${r}script"
    rscript_flags=('--vanilla')
    koopa::assert_is_installed "$r" "$rscript"
    koopa::alert 'Updating HTML package index.'
    doc_dir="$("$rscript" "${rscript_flags[@]}" -e 'cat(R.home("doc"))')"
    html_dir="${doc_dir}/html"
    [[ ! -d "$html_dir" ]] && koopa::mkdir -S "$html_dir"
    pkg_index="${html_dir}/packages.html"
    koopa::dl 'HTML index' "$pkg_index"
    [[ ! -f "$pkg_index" ]] && sudo touch "$pkg_index"
    r_css="${html_dir}/R.css"
    [[ ! -f "$r_css" ]] && sudo touch "$r_css"
    koopa::sys_set_permissions "$pkg_index"
    "$rscript" "${rscript_flags[@]}" -e 'utils::make.packages.html()'
}

koopa::rscript() { # {{{1
    # """
    # Execute an R script.
    # @note Updated 2021-01-06.
    # """
    local header_file flags fun pos
    koopa::assert_is_installed Rscript
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
    header_file="$(koopa::prefix)/lang/r/include/header.R"
    koopa::assert_is_file "$header_file"
    rscript="source('${header_file}')"
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed cleanly.
    if [[ "$fun" != 'header' ]]
    then
        rscript="${rscript}; koopa::${fun}()"
    fi
    # Ensure positional arguments get properly quoted (escaped) before handing
    # off to Rscript call.
    pos=("$@")
    # Argh, this printf method doesn't work.
    # > pos2=()
    # > for i in "${!pos[@]}"
    # > do
    # >     pos2+=("$(printf '%q\n' "${pos[$i]}")")
    # > done 
    # Alternate Bash 4.4 quoting approach: "${pos1[@]@Q}"
    Rscript "${flags[@]}" -e "$rscript" "${pos[@]@Q}"
    return 0
}

koopa::rscript_vanilla() { # {{{1
    # """
    # Run Rscript without configuration (vanilla mode).
    # @note Updated 2020-11-19.
    # """
    koopa::rscript --vanilla "$@"
    return 0
}

koopa::run_shiny_app() { # {{{1
    # """
    # Run Shiny application.
    # @note Updated 2021-04-07.
    # """
    local dir
    dir="${1:-.}"
    koopa::assert_is_installed R
    koopa::assert_is_dir "$dir"
    dir="$(koopa::realpath "$dir")"
    R \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dir}')"
    return 0
}
