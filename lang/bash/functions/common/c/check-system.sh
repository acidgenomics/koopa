#!/usr/bin/env bash

# FIXME This needs to check system Python and R versions.
# FIXME This isn't checking man linkage correctly currently.
# FIXME Check for current clang headers for system R on macOS.
# FIXME Just move all checks into Python code, for simplicity.
# TODO Can we check for current Xcode CLT on macOS?

koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2026-04-24.
    # """
    local -A dict
    koopa_assert_has_no_args "$#"
    koopa_check_build_system
    dict['bootstrap_prefix']="$(koopa_bootstrap_prefix)"
    if [[ -d "${dict['bootstrap_prefix']}" ]]
    then
        dict['expected_version_file']="${KOOPA_PREFIX:?}/etc/koopa/\
bootstrap-version.txt"
        dict['installed_version_file']="${dict['bootstrap_prefix']}/VERSION"
        if [[ -f "${dict['expected_version_file']}" ]] \
            && [[ -f "${dict['installed_version_file']}" ]]
        then
            dict['expected_version']="$( \
                cat "${dict['expected_version_file']}" \
            )"
            dict['installed_version']="$( \
                cat "${dict['installed_version_file']}" \
            )"
            if [[ "${dict['installed_version']}" \
                != "${dict['expected_version']}" ]]
            then
                koopa_warn "koopa bootstrap is out of date: \
${dict['installed_version']} != ${dict['expected_version']}."
                koopa_warn "Run 'koopa install user bootstrap' to update."
            fi
        else
            koopa_warn 'koopa bootstrap is out of date.'
            koopa_warn "Run 'koopa install user bootstrap' to update."
        fi
    fi
    koopa_python_script 'check-system.py'
    koopa_check_disk '/'
    # > koopa_check_exports
    koopa_alert_success 'System passed all checks.'
    return 0
}
