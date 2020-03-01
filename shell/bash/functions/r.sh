#!/usr/bin/env bash

_koopa_array_to_r_vector() {  # {{{1
    # """
    # Convert a bash array to an R vector string.
    # @note Updated 2019-09-25.
    #
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # """
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_koopa_r_javareconf() {  # {{{1
    # """
    # Update R Java configuration.
    # @note Updated 2020-02-29.
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
    _koopa_is_installed R || return 0
    _koopa_activate_openjdk
    _koopa_is_installed java || return 0

    local java_home
    java_home="$(_koopa_java_home)"
    [ -n "$java_home" ] && [ -d "$java_home" ] || return 1

    _koopa_h2 "Updating R Java configuration."

    local java_flags
    java_flags=(
        "JAVA_HOME=${java_home}"
        "JAVA=${java_home}/bin/java"
        "JAVAC=${java_home}/bin/javac"
        "JAVAH=${java_home}/bin/javah"
        "JAR=${java_home}/bin/jar"
    )

    # > local r_home
    # > r_home="$(_koopa_r_home)"
    # > if _koopa_is_cellar R
    # > then
    # >     _koopa_set_permissions --recursive "$r_home"
    # > fi

    R --vanilla CMD javareconf "${java_flags[@]}"

    # > if ! _koopa_is_r_package_installed rJava
    # > then
    # >     Rscript -e 'install.packages("rJava")'
    # > fi

    return 0
}
