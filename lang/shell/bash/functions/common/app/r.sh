#!/usr/bin/env bash

koopa_r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2022-01-20.
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
    local app dict java_args r_cmd
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
        [sudo]="$(koopa_locate_sudo)"
    )
    declare -A dict=(
        [java_home]="$(koopa_java_prefix)"
    )
    [[ -z "${app[r]:-}" ]] && app[r]="$(koopa_locate_r)"
    app[r]="$(koopa_which_realpath "${app[r]}")"
    if [[ ! -d "${dict[java_home]}" ]]
    then
        koopa_alert_note 'Skipping R Java configuration.'
        return 0
    fi
    dict[jar]="${dict[java_home]}/bin/jar"
    dict[java]="${dict[java_home]}/bin/java"
    dict[javac]="${dict[java_home]}/bin/javac"
    dict[javah]="${dict[java_home]}/bin/javah"
    koopa_alert 'Updating R Java configuration.'
    koopa_dl \
        'JAR' "${dict[jar]}" \
        'JAVA' "${dict[java]}" \
        'JAVAC' "${dict[javac]}" \
        'JAVAH' "${dict[javah]}" \
        'JAVA_HOME' "${dict[java_home]}" \
        'R' "${app[r]}"
    if koopa_is_koopa_app "${app[r]}"
    then
        r_cmd=("${app[r]}")
    else
        koopa_assert_is_admin
        r_cmd=("${app[sudo]}" "${app[r]}")
    fi
    java_args=(
        "JAR=${dict[jar]}"
        "JAVA=${dict[java]}"
        "JAVAC=${dict[javac]}"
        "JAVAH=${dict[javah]}"
        "JAVA_HOME=${dict[java_home]}"
    )
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}

koopa_r_link_files_into_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2022-01-25.
    #
    # Don't copy Makevars file across machines.
    # """
    local app dict file files
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    koopa_assert_is_installed "${app[r]}"
    app[r]="$(koopa_which_realpath "${app[r]}")"
    declare -A dict=(
        [distro_prefix]="$(koopa_distro_prefix)"
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [version]="$(koopa_r_version "${app[r]}")"
    )
    koopa_assert_is_dir "${dict[r_prefix]}"
    if [[ "${dict[version]}" != 'devel' ]]
    then
        dict[version]="$(koopa_major_minor_version "${dict[version]}")"
    fi
    dict[r_etc_source]="${dict[distro_prefix]}/etc/R/${dict[version]}"
    koopa_assert_is_dir "${dict[r_etc_source]}"
    if koopa_is_linux && \
        ! koopa_is_koopa_app "${app[r]}" && \
        [[ -d '/etc/R' ]]
    then
        # This applies to Debian/Ubuntu CRAN binary installs.
        dict[r_etc_target]='/etc/R'
    else
        dict[r_etc_target]="${dict[r_prefix]}/etc"
    fi
    files=(
        'Makevars.site'  # macOS
        'Renviron.site'
        'Rprofile.site'
        'repositories'
    )
    for file in "${files[@]}"
    do
        [[ -f "${dict[r_etc_source]}/${file}" ]] || continue
        koopa_sys_ln \
            "${dict[r_etc_source]}/${file}" \
            "${dict[r_etc_target]}/${file}"
    done
    return 0
}

koopa_r_link_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2022-01-20.
    #
    # R on Fedora won't pick up site library in '--vanilla' mode unless we
    # symlink the site-library into '/usr/local/lib/R' as well.
    # Refer to '/usr/lib64/R/etc/Renviron' for configuration details.
    #
    # Changed to unversioned library approach at opt prefix in koopa v0.9.
    # """
    local app conf_args dict
    koopa_assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
    )
    [[ -z "${app[r]}" ]] && app[r]="$(koopa_locate_r)"
    koopa_assert_is_installed "${app[r]}"
    declare -A dict=(
        [r_prefix]="$(koopa_r_prefix "${app[r]}")"
        [version]="$(koopa_r_version "${app[r]}")"
    )
    koopa_assert_is_dir "${dict[r_prefix]}"
    dict[lib_source]="$(koopa_r_packages_prefix "${dict[version]}")"
    dict[lib_target]="${dict[r_prefix]}/site-library"
    koopa_alert "Linking '${dict[lib_target]}' to '${dict[lib_source]}'."
    koopa_sys_mkdir "${dict[lib_source]}"
    if koopa_is_koopa_app "${app[r]}"
    then
        koopa_sys_ln "${dict[lib_source]}" "${dict[lib_target]}"
    else
        koopa_ln --sudo "${dict[lib_source]}" "${dict[lib_target]}"
    fi
    conf_args=(
        "--prefix=${dict[lib_source]}"
        '--name-fancy=R'
        '--name=r'
    )
    if [[ "${dict[version]}" == 'devel' ]]
    then
        conf_args+=(
            '--no-link'
        )
    fi
    koopa_configure_app_packages "${conf_args[@]}"
    if koopa_is_fedora && [[ -d '/usr/lib64/R' ]]
    then
        koopa_alert_note "Fixing Fedora R configuration at '/usr/lib64/R'."
        koopa_mkdir --sudo '/usr/lib64/R/site-library'
        koopa_ln --sudo \
            '/usr/lib64/R/site-library' \
            '/usr/local/lib/R/site-library'
    fi
    return 0
}

koopa_r_koopa() { # {{{1
    # """
    # Execute a function in koopa R package.
    # @note Updated 2021-10-29.
    # """
    local app code header_file fun pos rscript_args
    koopa_assert_has_args "$#"
    declare -A app=(
        [rscript]="$(koopa_locate_rscript)"
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    fun="${1:?}"
    shift 1
    header_file="$(koopa_koopa_prefix)/lang/r/include/header.R"
    koopa_assert_is_file "$header_file"
    code=("source('${header_file}');")
    # The 'header' variable is currently used to simply load the shared R
    # script header and check that the koopa R package is installed.
    if [[ "$fun" != 'header' ]]
    then
        code+=("koopa_${fun}();")
    fi
    # Ensure positional arguments get properly quoted (escaped).
    pos=("$@")
    "${app[rscript]}" "${rscript_args[@]}" -e "${code[*]}" "${pos[@]@Q}"
    return 0
}

koopa_r_paste_to_vector() { # {{{1
    # """
    # Paste a bash array into an R vector string.
    # @note Updated 2022-02-17.
    # """
    local str
    koopa_assert_has_args "$#"
    str="$(printf '"%s", ' "$@")"
    str="$(koopa_strip_right --pattern=', ' "$str")"
    str="$(printf 'c(%s)\n' "$str")"
    [[ -n "$str" ]] || return 1
    koopa_print "$str"
    return 0
}

koopa_r_rebuild_docs() { # {{{1
    # """
    # Rebuild R HTML/CSS files in 'docs' directory.
    # @note Updated 2022-01-31.
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
    local app doc_dir html_dir pkg_index rscript_args
    declare -A app=(
        [r]="${1:-}"
    )
    declare -A dict
    [[ -z "${app[r]:-}" ]] && app[r]="$(koopa_locate_r)"
    app[rscript]="${app[r]}script"
    koopa_assert_is_installed "${app[rscript]}"
    rscript_args=('--vanilla')
    koopa_alert 'Updating HTML package index.'
    dict[doc_dir]="$( \
        "${app[rscript]}" "${rscript_args[@]}" -e 'cat(R.home("doc"))' \
    )"
    dict[html_dir]="${dict[doc_dir]}/html"
    dict[pkg_index]="${dict[html_dir]}/packages.html"
    dict[r_css]="${dict[html_dir]}/R.css"
    if [[ ! -d "${dict[html_dir]}" ]]
    then
        koopa_mkdir --sudo "${dict[html_dir]}"
    fi
    if [[ ! -f "${dict[pkg_index]}" ]]
    then
        koopa_assert_is_admin
        koopa_touch --sudo "${dict[pkg_index]}"
    fi
    if [[ ! -f "${dict[r_css]}" ]]
    then
        koopa_assert_is_admin
        koopa_touch --sudo "${dict[r_css]}"
    fi
    koopa_sys_set_permissions "${dict[pkg_index]}"
    "${app[rscript]}" "${rscript_args[@]}" -e 'utils::make.packages.html()'
    return 0
}

koopa_r_shiny_run_app() { # {{{1
    # """
    # Run an R/Shiny application.
    # @note Updated 2022-02-11.
    # """
    local app dict
    declare -A app=(
        [r]="$(koopa_locate_r)"
    )
    declare -A dict=(
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="${PWD:?}"
    koopa_assert_is_dir "${dict[prefix]}"
    dict[prefix]="$(koopa_realpath "${dict[prefix]}")"
    "${app[r]}" \
        --no-restore \
        --no-save \
        --quiet \
        -e "shiny::runApp('${dict[prefix]}')"
    return 0
}
