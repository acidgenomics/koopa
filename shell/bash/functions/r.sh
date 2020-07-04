#!/usr/bin/env bash

koopa::array_to_r_vector() { # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2020-07-01.
    #
    # @examples
    # koopa::array_to_r_vector "aaa" "bbb"
    # ## c("aaa", "bbb")
    # """
    koopa::assert_has_args "$#"
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(koopa::strip_right ", " "$x")"
    x="$(printf "c(%s)\n" "$x")"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::link_r_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2020-07-01.
    #
    # Don't copy Makevars file across machines.
    # """
    koopa::assert_has_args_le "$#" 1
    local r_prefix
    r_prefix="${1:-$(koopa::r_prefix)}"
    if [[ ! -d "$r_prefix" ]]
    then
        koopa::warning "Failed to locate R prefix."
        return 1
    fi
    local r_exe
    r_exe="${r_prefix}/bin/R"
    local version
    version="$(koopa::r_version "$r_exe")"
    if [[ "$version" != "devel" ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    local koopa_prefix
    koopa_prefix="$(koopa::prefix)"
    # Locate the source etc directory in koopa.
    local os_id r_etc_source
    if koopa::is_linux && koopa::is_cellar "$r_prefix"
    then
        os_id="linux"
    else
        os_id="$(koopa::os_id)"
    fi
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R/${version}"
    if [[ ! -d "$r_etc_source" ]]
    then
        koopa::warning "Missing R etc source: '${r_etc_source}'."
        return 1
    fi
    local r_etc_target
    if koopa::is_linux && \
        ! koopa::is_cellar "$r_exe" && \
        [[ -d "/etc/R" ]]
    then
        # This currently applies to Debian/Ubuntu CRAN binary installs.
        r_etc_target="/etc/R"
    else
        r_etc_target="${r_prefix}/etc"
    fi
    local files
    files=(
        Makevars.site  # macOS
        Renviron.site
        Rprofile.site
        repositories
    )
    local file
    for file in "${files[@]}"
    do
        [[ -f "${r_etc_source}/${file}" ]] || continue
        koopa::system_ln "${r_etc_source}/${file}" "${r_etc_target}/${file}"
    done
    return 0
}

koopa::link_r_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2020-07-01.
    # """
    koopa::assert_has_args_le "$#" 1
    local r_prefix
    r_prefix="${1:-$(koopa::r_prefix)}"
    [[ -d "$r_prefix" ]] || return 1
    local r_exe
    r_exe="${r_prefix}/bin/R"
    [[ -x "$r_exe" ]] || return 1
    local version
    version="$(koopa::r_version "$r_exe")"
    if [[ "$version" != "devel" ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    local app_prefix
    app_prefix="$(koopa::app_prefix)"
    local lib_source
    lib_source="${app_prefix}/r/${version}/site-library"
    local lib_target
    lib_target="${r_prefix}/site-library"
    koopa::mkdir "$lib_source"
    koopa::system_ln "$lib_source" "$lib_target"
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2020-04-25.
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
    local java_home r_exe
    r_exe="R"
    while (("$#"))
    do
        case "$1" in
            --java-home=*)
                java_home="${1#*=}"
                shift 1
                ;;
            --java-home)
                java_home="$2"
                shift 2
                ;;
            --r-exe=*)
                r_exe="${1#*=}"
                shift 1
                ;;
            --r-exe)
                r_exe="$2"
                shift 2
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::is_installed "$r_exe" || return 0
    r_exe="$(koopa::which "$r_exe")"
    # Detect Java home automatically, if necessary.
    if [[ -z "${java_home:-}" ]]
    then
        koopa::activate_openjdk
        java_home="$(koopa::java_prefix)"
        koopa::is_installed java || return 0
    fi
    [[ -d "$java_home" ]] || return 1
    koopa::h2 "Updating R Java configuration."
    koopa::dl "R" "$r_exe"
    koopa::dl "Java home" "$java_home"
    local java_flags
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    if koopa::is_cellar "$r_exe"
    then
        "$r_exe" --vanilla CMD javareconf "${java_flags[@]}"
    else
        sudo "$r_exe" --vanilla CMD javareconf "${java_flags[@]}"
    fi
    return 0
}

koopa::update_r_config() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2020-07-01.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    koopa::assert_has_args_le "$#" 1
    koopa::h1 "Updating R configuration."
    # Locate R command.
    local r_exe
    r_exe="${1:-}"
    if [[ -z "$r_exe" ]]
    then
        r_exe="$(koopa::which_realpath R)"
    fi
    # Locate Rscript command.
    local rscript_exe
    rscript_exe="${r_exe}script"
    koopa::assert_is_installed "$r_exe" "$rscript_exe"
    local r_prefix
    r_prefix="$(koopa::r_prefix "$rscript_exe")"
    koopa::dl "R home" "$r_prefix"
    koopa::dl "R path" "$r_exe"
    koopa::dl "Rscript path" "$rscript_exe"
    if koopa::is_cellar "$r_exe"
    then
        # Ensure that everyone in R home is writable.
        koopa::system_set_permissions --recursive "$r_prefix"
        # Ensure that (Debian) system 'etc' directories are removed.
        local make_prefix
        make_prefix="$(koopa::make_prefix)"
        local etc_prefix
        etc_prefix="${make_prefix}/lib/R/etc"
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            koopa::system_rm "$etc_prefix"
        fi
        etc_prefix="${make_prefix}/lib64/R/etc"
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            koopa::system_rm "$etc_prefix"
        fi
    else
        # Ensure system package library is writable.
        koopa::system_set_permissions --recursive "${r_prefix}/library"
        # Need to ensure group write so package index gets updated.
        if [[ -d '/usr/share/R' ]]
        then
            koopa::system_set_permissions '/usr/share/R/doc/html/packages.html'
        fi
    fi
    koopa::link_r_etc "$r_prefix"
    koopa::link_r_site_library "$r_prefix"
    koopa::r_javareconf --r-exe="$r_exe"
    return 0
}
