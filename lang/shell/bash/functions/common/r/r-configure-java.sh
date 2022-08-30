#!/usr/bin/env bash

koopa_r_configure_java() {
    # """
    # Update R Java configuration.
    # @note Updated 2022-08-29.
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
    #
    # @seealso
    # - JAVAH deprecated in JDK 9.
    #   https://docs.oracle.com/javase/9/tools/javah.htm#JSWOR687
    # """
    local app conf_dict dict java_args
    koopa_assert_has_args_eq "$#" 1
    declare -A app
    app['r']="${1:?}"
    [[ -x "${app['r']}" ]] || return 1
    koopa_is_koopa_app "${app['r']}" && return 0
    declare -A dict
    dict['openjdk']="$(koopa_app_prefix 'openjdk' || true)"
    if [[ ! -d "${dict['openjdk']}" ]]
    then
        koopa_alert_note 'Skipping R Java configuration.'
        return 0
    fi
    koopa_alert 'Updating R Java configuration.'
    koopa_assert_is_admin
    app['sudo']="$(koopa_locate_sudo)"
    app['jar']="$(koopa_locate_jar --realpath)"
    app['java']="$(koopa_locate_java --realpath)"
    app['javac']="$(koopa_locate_javac --realpath)"
    [[ -x "${app['sudo']}" ]] || return 1
    [[ -x "${app['jar']}" ]] || return 1
    [[ -x "${app['java']}" ]] || return 1
    [[ -x "${app['javac']}" ]] || return 1
    declare -A conf_dict=(
        ['java_home']="${dict['openjdk']}"
        ['jar']="${app['jar']}"
        ['java']="${app['java']}"
        ['javac']="${app['javac']}"
        ['javah']=''
    )
    java_args=(
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
    )
    "${app['sudo']}" "${app['r']}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}
