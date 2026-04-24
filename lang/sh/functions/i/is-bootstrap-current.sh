#!/bin/sh

_koopa_is_bootstrap_current() {
    # """
    # Is the koopa bootstrap installation current?
    # @note Updated 2026-04-24.
    #
    # Compares the installed bootstrap VERSION against the expected version
    # defined in 'etc/koopa/bootstrap-version.txt'.
    #
    # Returns 0 (true) if versions match, 1 (false) otherwise.
    # """
    __kvar_bootstrap_prefix="$(_koopa_bootstrap_prefix)"
    __kvar_installed_version_file="${__kvar_bootstrap_prefix}/VERSION"
    __kvar_expected_version_file="${KOOPA_PREFIX:?}/etc/koopa/bootstrap-version.txt"
    if [ ! -f "$__kvar_expected_version_file" ]
    then
        unset -v \
            __kvar_bootstrap_prefix \
            __kvar_expected_version_file \
            __kvar_installed_version_file
        return 1
    fi
    if [ ! -f "$__kvar_installed_version_file" ]
    then
        unset -v \
            __kvar_bootstrap_prefix \
            __kvar_expected_version_file \
            __kvar_installed_version_file
        return 1
    fi
    __kvar_expected_version="$(cat "$__kvar_expected_version_file")"
    __kvar_installed_version="$(cat "$__kvar_installed_version_file")"
    if [ "$__kvar_installed_version" = "$__kvar_expected_version" ]
    then
        unset -v \
            __kvar_bootstrap_prefix \
            __kvar_expected_version \
            __kvar_expected_version_file \
            __kvar_installed_version \
            __kvar_installed_version_file
        return 0
    fi
    unset -v \
        __kvar_bootstrap_prefix \
        __kvar_expected_version \
        __kvar_expected_version_file \
        __kvar_installed_version \
        __kvar_installed_version_file
    return 1
}
