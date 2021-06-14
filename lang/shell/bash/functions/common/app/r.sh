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

# FIXME This isn't working correctly for 'r-devel'. May need to rethink.
koopa::r_link_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2021-06-14.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local conf_args lib_source lib_target name r r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-}"
    [[ -z "$r" ]] && r="$(koopa::locate_r)"
    koopa::assert_is_installed "$r"
    name='r'
    r_prefix="$(koopa::r_prefix "$r")"
    koopa::assert_is_dir "$r_prefix"
    # FIXME Is this returning 'devel' or the revision number?
    version="$(koopa::r_version "$r")"
    lib_source="$(koopa::r_packages_prefix "$version")"
    lib_target="${r_prefix}/site-library"
    koopa::alert "Adding '${lib_target}' symbolic link."
    koopa::sys_mkdir "$lib_source"
    if koopa::is_symlinked_app "$r"
    then
        koopa::sys_ln "$lib_source" "$lib_target"
        if ! koopa::is_macos
        then
            koopa::link_app "$name"
        fi
    else
        koopa::ln -S "$lib_source" "$lib_target"
    fi
    conf_args=(
        "--prefix=${lib_source}"
    )
    # FIXME I think this isn't catching correctly, not picking up devel here?
    if [[ "$version" == 'devel' ]]
    then
        conf_args+=(
            '--name-fancy=R-devel'
            '--name=r-devel'
            '--no-link'
        )
    else
        conf_args+=(
            '--name-fancy=R'
            '--name=r'
        )
    fi
    koopa:::configure_app_packages "${conf_args[@]}"
    if koopa::is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa::alert_note 'Fixing Fedora R configuration.'
        koopa::ln -S \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2021-05-05.
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
    if [[ -z "${java_home:-}" ]]
    then
        koopa::activate_openjdk
        java_home="$(koopa::java_prefix)"
        if ! koopa::is_installed 'java'
        then
            koopa::alert_note "Failed to locate 'java'."
            return 0
        fi
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
