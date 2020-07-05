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
    # @note Updated 2020-07-04.
    #
    # Don't copy Makevars file across machines.
    # """
    koopa::assert_has_args_le "$#" 1
    local file files koopa_prefix os_id r r_etc_source r_etc_target \
        r_prefix version
    r="${1:-R}"
    koopa::is_installed "$r" || return 1
    r_prefix="$(koopa::r_prefix "$r")"
    [[ -d "$r_prefix" ]] || return 1
    version="$(koopa::r_version "$r")"
    if [[ "$version" != 'devel' ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    koopa_prefix="$(koopa::prefix)"
    if koopa::is_linux && koopa::is_cellar "$r_prefix"
    then
        os_id='linux'
    else
        os_id="$(koopa::os_id)"
    fi
    r_etc_source="${koopa_prefix}/os/${os_id}/etc/R/${version}"
    if [[ ! -d "$r_etc_source" ]]
    then
        koopa::warning "Missing R etc source: '${r_etc_source}'."
        return 1
    fi
    if koopa::is_linux && \
        ! koopa::is_cellar "$r_exe" && \
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
    # @note Updated 2020-07-04.
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
    if [[ "$version" != 'devel' ]]
    then
        version="$(koopa::major_minor_version "$version")"
    fi
    local app_prefix
    app_prefix="$(koopa::app_prefix)"
    local lib_source
    lib_source="${app_prefix}/r/${version}/site-library"
    local lib_target
    lib_target="${r_prefix}/site-library"
    koopa::sys_mkdir "$lib_source"
    koopa::sys_ln "$lib_source" "$lib_target"
    return 0
}

koopa::r_javareconf() { # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2020-07-05.
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
            --java-home)
                java_home="$2"
                shift 2
                ;;
            --r=*)
                r="${1#*=}"
                shift 1
                ;;
            --r)
                r="$2"
                shift 2
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
    [[ -d "$java_home" ]] || return 1
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

# FIXME DOUBLE CHECK THIS WORKS.
koopa::update_r_config() { # {{{1
    # """
    # Update R configuration.
    # @note Updated 2020-07-05.
    #
    # Add shared R configuration symlinks in '${R_HOME}/etc'.
    # """
    koopa::assert_has_args_le "$#" 1
    local r r_prefix
    r="${1:-R}"
    r="$(koopa::which_realpath "$r")"
    koopa::assert_is_installed "$r"
    r_prefix="$(koopa::r_prefix "$r_prefix")"
    koopa::h1 'Updating R configuration.'
    koopa::dl 'R home' "$r_prefix"
    koopa::dl 'R path' "$r"
    if koopa::is_cellar "$r"
    then
        # Ensure that everyone in R home is writable.
        koopa::sys_set_permissions --recursive "$r_prefix"
        # Ensure that (Debian) system 'etc' directories are removed.
        local make_prefix
        make_prefix="$(koopa::make_prefix)"
        local etc_prefix
        etc_prefix="${make_prefix}/lib/R/etc"
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
        # Ensure system package library is writable.
        koopa::sys_set_permissions --recursive "${r_prefix}/library"
        # Need to ensure group write so package index gets updated.
        if [[ -d '/usr/share/R' ]]
        then
            koopa::sys_set_permissions '/usr/share/R/doc/html/packages.html'
        fi
    fi
    koopa::link_r_etc "$r"
    koopa::link_r_site_library "$r"
    koopa::r_javareconf "$r"
    return 0
}
