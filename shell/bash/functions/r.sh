#!/usr/bin/env bash

_koopa_array_to_r_vector() { # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2020-07-01.
    #
    # @examples
    # _koopa_array_to_r_vector "aaa" "bbb"
    # ## c("aaa", "bbb")
    # """
    _koopa_assert_has_args "$#"
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right ", " "$x")"
    x="$(printf "c(%s)\n" "$x")"
    [[ -n "$x" ]] || return 1
    _koopa_print "$x"
    return 0
}

_koopa_link_r_etc() { # {{{1
    # """
    # Link R config files inside 'etc/'.
    # @note Updated 2020-07-01.
    #
    # Don't copy Makevars file across machines.
    # """
    _koopa_assert_has_args_le "$#" 1
    local r_prefix
    r_prefix="${1:-$(_koopa_r_prefix)}"
    if [[ ! -d "$r_prefix" ]]
    then
        _koopa_warning "Failed to locate R prefix."
        return 1
    fi
    local r_exe
    r_exe="${r_prefix}/bin/R"
    local version
    version="$(_koopa_r_version "$r_exe")"
    if [[ "$version" != "devel" ]]
    then
        version="$(_koopa_major_minor_version "$version")"
    fi
    local koopa_prefix
    koopa_prefix="$(_koopa_prefix)"
    # Locate the source etc directory in koopa.
    local os_id r_etc_source
    if _koopa_is_linux && _koopa_is_cellar "$r_prefix"
    then
        os_id="linux"
    else
        os_id="$(_koopa_os_id)"
    fi
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R/${version}"
    if [[ ! -d "$r_etc_source" ]]
    then
        _koopa_warning "Missing R etc source: '${r_etc_source}'."
        return 1
    fi
    local r_etc_target
    if _koopa_is_linux && \
        ! _koopa_is_cellar "$r_exe" && \
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
        _koopa_ln "${r_etc_source}/${file}" "${r_etc_target}/${file}"
    done
    return 0
}

_koopa_link_r_site_library() { # {{{1
    # """
    # Link R site library.
    # @note Updated 2020-07-01.
    # """
    _koopa_assert_has_args_le "$#" 1
    local r_prefix
    r_prefix="${1:-$(_koopa_r_prefix)}"
    [[ -d "$r_prefix" ]] || return 1
    local r_exe
    r_exe="${r_prefix}/bin/R"
    [[ -x "$r_exe" ]] || return 1
    local version
    version="$(_koopa_r_version "$r_exe")"
    if [[ "$version" != "devel" ]]
    then
        version="$(_koopa_major_minor_version "$version")"
    fi
    local app_prefix
    app_prefix="$(_koopa_app_prefix)"
    local lib_source
    lib_source="${app_prefix}/r/${version}/site-library"
    local lib_target
    lib_target="${r_prefix}/site-library"
    _koopa_mkdir "$lib_source"
    _koopa_ln "$lib_source" "$lib_target"
    return 0
}

_koopa_r_javareconf() { # {{{1
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
                _koopa_invalid_arg "$1"
                ;;
        esac
    done
    _koopa_is_installed "$r_exe" || return 0
    r_exe="$(_koopa_which "$r_exe")"
    # Detect Java home automatically, if necessary.
    if [[ -z "${java_home:-}" ]]
    then
        _koopa_activate_openjdk
        java_home="$(_koopa_java_prefix)"
        _koopa_is_installed java || return 0
    fi
    [[ -d "$java_home" ]] || return 1
    _koopa_h2 "Updating R Java configuration."
    _koopa_dl "R" "$r_exe"
    _koopa_dl "Java home" "$java_home"
    local java_flags
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )
    if _koopa_is_cellar "$r_exe"
    then
        "$r_exe" --vanilla CMD javareconf "${java_flags[@]}"
    else
        sudo "$r_exe" --vanilla CMD javareconf "${java_flags[@]}"
    fi
    return 0
}

_koopa_update_r_config() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2020-07-01.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    _koopa_assert_has_args_le "$#" 1
    _koopa_h1 "Updating R configuration."
    # Locate R command.
    local r_exe
    r_exe="${1:-}"
    if [[ -z "$r_exe" ]]
    then
        r_exe="$(_koopa_which_realpath R)"
    fi
    # Locate Rscript command.
    local rscript_exe
    rscript_exe="${r_exe}script"
    _koopa_assert_is_installed "$r_exe" "$rscript_exe"
    local r_prefix
    r_prefix="$(_koopa_r_prefix "$rscript_exe")"
    _koopa_dl "R home" "$r_prefix"
    _koopa_dl "R path" "$r_exe"
    _koopa_dl "Rscript path" "$rscript_exe"
    if _koopa_is_cellar "$r_exe"
    then
        # Ensure that everyone in R home is writable.
        _koopa_set_permissions --recursive "$r_prefix"
        # Ensure that (Debian) system 'etc' directories are removed.
        local make_prefix
        make_prefix="$(_koopa_make_prefix)"
        local etc_prefix
        etc_prefix="${make_prefix}/lib/R/etc"
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            _koopa_rm "$etc_prefix"
        fi
        etc_prefix="${make_prefix}/lib64/R/etc"
        if [[ -d "$etc_prefix" ]] && [[ ! -L "$etc_prefix" ]]
        then
            _koopa_rm "$etc_prefix"
        fi
    else
        # Ensure system package library is writable.
        _koopa_set_permissions --recursive "${r_prefix}/library"
        # Need to ensure group write so package index gets updated.
        if [[ -d '/usr/share/R' ]]
        then
            _koopa_set_permissions '/usr/share/R/doc/html/packages.html'
        fi
    fi
    _koopa_link_r_etc "$r_prefix"
    _koopa_link_r_site_library "$r_prefix"
    _koopa_r_javareconf --r-exe="$r_exe"
    return 0
}
