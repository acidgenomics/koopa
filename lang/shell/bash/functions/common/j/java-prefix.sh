#!/usr/bin/env bash

koopa_java_prefix() {
    # """
    # Java prefix.
    # @note Updated 2022-05-20.
    #
    # See also:
    # - https://www.mkyong.com/java/
    #       how-to-set-java_home-environment-variable-on-mac-os-x/
    # - https://stackoverflow.com/questions/22290554
    # """
    local prefix
    if [[ -n "${JAVA_HOME:-}" ]]
    then
        koopa_print "$JAVA_HOME"
        return 0
    fi
    if [[ -d "$(koopa_openjdk_prefix)" ]]
    then
        koopa_print "$(koopa_openjdk_prefix)"
        return 0
    fi
    if [[ -x '/usr/libexec/java_home' ]]
    then
        prefix="$('/usr/libexec/java_home' || true)"
        [ -n "$prefix" ] || return 1
        koopa_print "$prefix"
        return 0
    fi
    if [[ -d "$(koopa_homebrew_opt_prefix)/openjdk" ]]
    then
        koopa_print "$(koopa_homebrew_opt_prefix)/openjdk"
        return 0
    fi
    return 1
}
