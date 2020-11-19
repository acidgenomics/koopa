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
    # @note Updated 2020-11-19.
    # """
    koopa::assert_has_args "$#"
    koopa::rscript 'drat' "$@"
    return 0
}

koopa::install_rcheck() { # {{{1
    # """
    # Install Rcheck scripts for CI.
    # @note Updated 2020-07-08.
    # """
    local link_name name source_repo target_dir
    koopa::assert_has_no_args "$#"
    name='Rcheck'
    source_repo="https://github.com/acidgenomics/${name}.git"
    target_dir="$(koopa::local_app_prefix)/${name}"
    link_name=".${name}"
    koopa::install_start "$name"
    if [[ ! -d "$target_dir" ]]
    then
        koopa::h2 "Downloading ${name} to '${target_dir}'."
        (
            koopa::mkdir "$target_dir"
            git clone "$source_repo" "$target_dir"
        )
    fi
    koopa::ln "$target_dir" "$link_name"
    koopa::install_success "$name"
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
        ! koopa::is_cellar "$r" && \
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

koopa::link_r_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2020-11-11.
    # """
    local app_prefix lib_source lib_target r r_prefix version
    koopa::assert_has_args_le "$#" 1
    r="${1:-R}"
    r_prefix="$(koopa::r_prefix "$r")"
    [[ -d "$r_prefix" ]] || return 1
    version="$(koopa::r_version "$r")"
    if [[ "$version" != 'devel' ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    app_prefix="$(koopa::app_prefix)"
    lib_source="${app_prefix}/r/${version}/site-library"
    lib_target="${r_prefix}/site-library"
    koopa::sys_mkdir "$lib_source"
    koopa::sys_ln "$lib_source" "$lib_target"
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    if koopa::is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa::sys_ln \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2020-11-11.
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
    if [[ ! -d "$java_home" ]]
    then
        koopa_stop 'Failed to locate JAVA_HOME.'
    fi
    koopa::h2 'Updating R Java configuration.'
    koopa::dl 'R' "$r"
    koopa::dl 'Java home' "$java_home"
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    if koopa::is_cellar "$r"
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
    koopa::h2 'Updating HTML package index.'
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
    # @note Updated 2020-11-19.
    #
    # This function allows passthrough of flags such as '--vanilla'.
    # """
    local args name pos prefix script vanilla
    koopa::assert_is_installed Rscript
    prefix="$(koopa::rscript_prefix)"
    vanilla=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --vanilla)
                vanilla=1
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
    koopa::assert_has_args "$#"
    name="${1:?}"
    shift 1
    script="${prefix}/${name}.R"
    koopa::assert_is_file "$script"
    args=()
    [[ "$vanilla" -eq 1 ]] && args+=('--vanilla')
    args+=("$script" "$@")
    Rscript "${args[@]}"
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

koopa::update_r_config() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2020-11-11.
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
    if koopa::is_cellar "$r"
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
    koopa::install_r_koopa
    koopa::success 'Update of R configuration was successful.'
    return 0
}
