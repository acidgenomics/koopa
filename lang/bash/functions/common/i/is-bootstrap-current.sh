#!/usr/bin/env bash

koopa_is_bootstrap_current() {
    # """
    # Is the koopa bootstrap installation current?
    # @note Updated 2026-04-24.
    #
    # Compares the installed bootstrap VERSION against the expected version
    # defined in 'etc/koopa/bootstrap-version.txt'.
    #
    # Returns 0 (true) if versions match, 1 (false) otherwise.
    # """
    local -A dict
    dict['bootstrap_prefix']="$(koopa_bootstrap_prefix)"
    dict['installed_version_file']="${dict['bootstrap_prefix']}/VERSION"
    dict['expected_version_file']="${KOOPA_PREFIX:?}/etc/koopa/bootstrap-version.txt"
    [[ -f "${dict['expected_version_file']}" ]] || return 1
    [[ -f "${dict['installed_version_file']}" ]] || return 1
    dict['expected_version']="$(cat "${dict['expected_version_file']}")"
    dict['installed_version']="$(cat "${dict['installed_version_file']}")"
    [[ "${dict['installed_version']}" == "${dict['expected_version']}" ]]
}
