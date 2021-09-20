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

koopa::drat() { # {{{
    # """
    # Add R package to drat repository.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDrat' "$@"
    return 0
}

koopa::download_ensembl_genome() { # {{{1
    # """
    # Download Ensembl genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadEnsemblGenome' "$@"
    return 0
}

koopa::download_gencode_genome() { # {{{1
    # """
    # Download GENCODE genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadGencodeGenome' "$@"
    return 0
}

koopa::download_refseq_genome() { # {{{1
    # """
    # Download RefSeq genome.
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadRefseqGenome' "$@"
    return 0
}

koopa::download_ucsc_genome() { # {{{1
    # """
    # Download UCSC genome.
    # @note Updated 2021-08-18.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliDownloadUCSCGenome' "$@"
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
    # @note Updated 2021-08-14.
    # """
    koopa::assert_has_args "$#"
    koopa::r_koopa 'cliPkgdownDeployToAWS' "$@"
    return 0
}

koopa::r_link_files_into_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2021-04-29.
    #
    # Don't copy Makevars file across machines.
    # """
    local distro_prefix file files r r_etc_source r_etc_target r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-$(koopa::locate_r)}"
    koopa::assert_is_installed "$r"
    r="$(koopa::which_realpath "$r")"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    version="$(koopa::r_version "$r")"
    if [[ "$version" != 'devel' ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    distro_prefix="$(koopa::distro_prefix)"
    r_etc_source="${distro_prefix}/etc/R/${version}"
    koopa::assert_is_dir "$r_etc_source"
    if koopa::is_linux && \
        ! koopa::is_koopa_app "$r" && \
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

koopa::r_link_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2021-06-16.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local conf_args lib_source lib_target r r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    koopa::assert_is_installed "$r"
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    version="$(koopa::r_version "$r")"
    lib_source="$(koopa::r_packages_prefix "$version")"
    lib_target="${r_prefix}/site-library"
    koopa::alert "Linking '${lib_target}' to '${lib_source}'."
    koopa::sys_mkdir "$lib_source"
    if koopa::is_koopa_app "$r"
    then
        koopa::sys_ln "$lib_source" "$lib_target"
    else
        koopa::ln -S "$lib_source" "$lib_target"
    fi
    conf_args=(
        "--prefix=${lib_source}"
        '--name-fancy=R'
        '--name=r'
    )
    if [[ "$version" == 'devel' ]]
    then
        conf_args+=(
            '--no-link'
        )
    fi
    koopa:::configure_app_packages "${conf_args[@]}"
    if koopa::is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa::alert_note "Fixing Fedora R configuration at '/usr/lib64/R'."
        koopa::mkdir -S '/usr/lib64/R/site-library'
        koopa::ln -S \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2021-09-14.
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
    local java_flags java_home r r_cmd
    koopa::assert_has_args_le "$#" 1
    r="${1:-$(koopa::locate_r)}"
    koopa::assert_is_installed "$r"
    r="$(koopa::which_realpath "$r")"
    koopa::activate_openjdk
    koopa::assert_is_installed 'java'
    java_home="$(koopa::java_prefix)"
    koopa::assert_is_dir "$java_home"
    koopa::alert 'Updating R Java configuration.'
    koopa::dl \
        'R' "$r" \
        'Java home' "$java_home"
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    if koopa::is_koopa_app "$r"
    then
        r_cmd=("$r")
    else
        koopa::assert_is_admin
        r_cmd=('sudo' "$r")
    fi
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_flags[@]}"
    return 0
}

koopa::r_rebuild_docs() { # {{{1
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2021-04-29.
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
    r="${1:-$(koopa::locate_r)}"
    rscript="${r}script"
    koopa::assert_is_installed "$r" "$rscript"
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

koopa::r_koopa() { # {{{1
    # """
    # Execute a function in koopa R package.
    # @note Updated 2021-08-17.
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
            '--vanilla')
                flags+=('--vanilla')
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
    code=()
    code+=("source('${header_file}');")
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    if [[ "$fun" != 'header' ]]
    then
        code+=("koopa::${fun}();")
    fi
    # Ensure positional arguments get properly quoted (escaped).
    pos=("$@")
    "$rscript" "${flags[@]}" -e "${code[*]}" "${pos[@]@Q}"
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
