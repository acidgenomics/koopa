#!/usr/bin/env bash

koopa_r_javareconf() {
    # """
    # Update R Java configuration.
    # @note Updated 2022-07-11.
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
    koopa_assert_has_args_eq "$#" 1
    declare -A app=(
        [r]="${1:?}"
        [sudo]="$(koopa_locate_sudo)"
    )
    [[ -x "${app[r]}" ]] || return 1
    [[ -x "${app[sudo]}" ]] || return 1
    declare -A dict=(
        [java_home]="$(koopa_java_prefix)"
    )
    if [[ ! -d "${dict[java_home]}" ]]
    then
        koopa_alert_note 'Skipping R Java configuration.'
        return 0
    fi
    dict[jar]="${dict[java_home]}/bin/jar"
    dict[java]="${dict[java_home]}/bin/java"
    dict[javac]="${dict[java_home]}/bin/javac"
    koopa_alert 'Updating R Java configuration.'
    koopa_dl \
        'JAR' "${dict[jar]}" \
        'JAVA' "${dict[java]}" \
        'JAVAC' "${dict[javac]}" \
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
        "JAVA_HOME=${dict[java_home]}"
    )
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}
