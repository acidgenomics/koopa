#!/usr/bin/env bash

koopa_r_configure_java() {
    # """
    # Update R Java configuration.
    # @note Updated 2025-02-18.
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
    local -A app bool conf_dict dict
    local -a java_args r_cmd
    koopa_assert_has_args_eq "$#" 1
    app['r']="${1:?}"
    koopa_assert_is_executable "${app[@]}"
    bool['system']=0
    bool['use_apps']=1
    ! koopa_is_koopa_app "${app['r']}" && bool['system']=1
    if [[ "${bool['system']}" -eq 1 ]]
    then
        koopa_is_macos || return 0
        koopa_has_standard_umask || return 0
        bool['use_apps']=0
    fi
    if [[ "${bool['use_apps']}" -eq 1 ]]
    then
        dict['java_home']="$(koopa_app_prefix 'temurin')"
    else
        if koopa_is_linux
        then
            dict['java_home']='/usr/lib/jvm/default-java'
        elif koopa_is_macos
        then
            # NOTE This will error if Temurin cask isn't installed.
            dict['java_home']="$(/usr/libexec/java_home || true)"
        fi
    fi
    if [[ ! -d "${dict['java_home']}" ]]
    then
        koopa_alert_note "Failed to detected system Java. \
Skipping configuration."
        return 0
    fi
    app['jar']="${dict['java_home']}/bin/jar"
    app['java']="${dict['java_home']}/bin/java"
    app['javac']="${dict['java_home']}/bin/javac"
    koopa_assert_is_executable "${app[@]}"
    koopa_alert_info "Using Java SDK at '${dict['java_home']}'."
    conf_dict['java_home']="${dict['java_home']}"
    conf_dict['jar']="${app['jar']}"
    conf_dict['java']="${app['java']}"
    conf_dict['javac']="${app['javac']}"
    conf_dict['javah']=''
    java_args=(
        "JAR=${conf_dict['jar']}"
        "JAVA=${conf_dict['java']}"
        "JAVAC=${conf_dict['javac']}"
        "JAVAH=${conf_dict['javah']}"
        "JAVA_HOME=${conf_dict['java_home']}"
    )
    if [[ "${bool['system']}" -eq 1 ]]
    then
        r_cmd=('koopa_sudo' "${app['r']}")
    else
        r_cmd=("${app['r']}")
    fi
    koopa_assert_is_executable "${app[@]}"
    "${r_cmd[@]}" --vanilla CMD javareconf "${java_args[@]}"
    return 0
}
