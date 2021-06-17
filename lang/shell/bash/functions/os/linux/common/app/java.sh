#!/usr/bin/env bash

koopa::linux_java_update_alternatives() { # {{{1
    # """
    # Update Java alternatives.
    # @note Updated 2021-06-04.
    #
    # This step is intentionally skipped for non-admin installs, when calling
    # from 'install-openjdk' script.
    # """
    local prefix priority
    koopa::assert_has_args_eq "$#" 1
    koopa::is_shared_install || return 0
    koopa::assert_is_installed 'update-alternatives'
    prefix="${1:?}"
    prefix="$(koopa::realpath "$prefix")"
    priority=100
    sudo rm -fv /var/lib/alternatives/java
    sudo update-alternatives --install \
        '/usr/bin/java' \
        'java' \
        "${prefix}/bin/java" \
        "$priority"
    sudo update-alternatives --set \
        'java' \
        "${prefix}/bin/java"
    sudo rm -fv /var/lib/alternatives/javac
    sudo update-alternatives --install \
        '/usr/bin/javac' \
        'javac' \
        "${prefix}/bin/javac" \
        "$priority"
    sudo update-alternatives --set \
        'javac' \
        "${prefix}/bin/javac"
    sudo rm -fv /var/lib/alternatives/jar
    sudo update-alternatives --install \
        '/usr/bin/jar' \
        'jar' \
        "${prefix}/bin/jar" \
        "$priority"
    sudo update-alternatives --set \
        'jar' \
        "${prefix}/bin/jar"
    update-alternatives --display java
    update-alternatives --display javac
    update-alternatives --display jar
    return 0
}
