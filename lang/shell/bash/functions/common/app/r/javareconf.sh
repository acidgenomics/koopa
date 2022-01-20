#!/usr/bin/env bash

koopa::r_javareconf() { # {{{1
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
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [r]="${1:-}"
        [sudo]="$(koopa::locate_sudo)"
    )
    declare -A dict=(
        [java_home]="$(koopa::java_prefix)"
    )
    [[ -z "${app[r]:-}" ]] && app[r]="$(koopa::locate_r)"
    app[r]="$(koopa::which_realpath "${app[r]}")"
    if [[ ! -d "${dict[java_home]}" ]]
    then
        koopa::alert_note 'Skipping R Java configuration.'
        return 0
    fi
    dict[jar]="${dict[java_home]}/bin/jar"
    dict[java]="${dict[java_home]}/bin/java"
    dict[javac]="${dict[java_home]}/bin/javac"
    dict[javah]="${dict[java_home]}/bin/javah"
    koopa::alert 'Updating R Java configuration.'
    koopa::dl \
        'JAR' "${dict[jar]}" \
        'JAVA' "${dict[java]}" \
        'JAVAC' "${dict[javac]}" \
        'JAVAH' "${dict[javah]}" \
        'JAVA_HOME' "${dict[java_home]}" \
        'R' "${app[r]}"
    if koopa::is_koopa_app "${app[r]}"
    then
        r_cmd=("${app[r]}")
    else
        koopa::assert_is_admin
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
