#!/usr/bin/env bash

koopa::linux_java_update_alternatives() { # {{{1
    # """
    # Update Java alternatives.
    # @note Updated 2021-11-16.
    #
    # This step is intentionally skipped for non-admin installs, when calling
    # from 'install-openjdk' script.
    # """
    local app dict
    local prefix priority
    koopa::assert_has_args_eq "$#" 1
    koopa::assert_is_admin
    declare -A app=(
        [sudo]="$(koopa::locate_sudo)"
        [update_alternatives]="$(koopa::linux_locate_update_alternatives)"
    )
    declare -A dict=(
        [alt_prefix]='/var/lib/alternatives'
        [prefix]="$(koopa::realpath "${1:?}")"
        [priority]=100
    )
    koopa::rm --sudo \
        "${dict[alt_prefix]}/java" \
        "${dict[alt_prefix]}/javac" \
        "${dict[alt_prefix]}/jar"
    "${app[sudo]}" "${app[update_alternatives]}" --install \
        '/usr/bin/java' \
        'java' \
        "${dict[prefix]}/bin/java" \
        "${dict[priority]}"
    "${app[sudo]}" "${app[update_alternatives]}" --install \
        '/usr/bin/javac' \
        'javac' \
        "${dict[prefix]}/bin/javac" \
        "${dict[priority]}"
    "${app[sudo]}" "${app[update_alternatives]}" --install \
        '/usr/bin/jar' \
        'jar' \
        "${dict[prefix]}/bin/jar" \
        "${dict[priority]}"
    "${app[sudo]}" "${app[update_alternatives]}" --set \
        'java' \
        "${dict[prefix]}/bin/java"
    "${app[sudo]}" "${app[update_alternatives]}" --set \
        'javac' \
        "${dict[prefix]}/bin/javac"
    "${app[sudo]}" "${app[update_alternatives]}" --set \
        'jar' \
        "${dict[prefix]}/bin/jar"
    "${app[update_alternatives]}" --display 'java'
    "${app[update_alternatives]}" --display 'javac'
    "${app[update_alternatives]}" --display 'jar'
    return 0
}
