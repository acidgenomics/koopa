#!/usr/bin/env bash

# FIXME This needs to check system Python and R versions.
# FIXME This isn't checking man linkage correctly currently.
# FIXME Check for current clang headers for system R on macOS.
# FIXME Just move all checks into Python code, for simplicity.
# TODO Can we check for current Xcode CLT on macOS?

_koopa_check_system() {
    # """
    # Check system.
    # @note Updated 2026-04-24.
    # """
    local -A bool dict
    _koopa_assert_has_no_args "$#"
    bool['warnings']=0
    _koopa_check_build_system
    dict['bootstrap_prefix']="$(_koopa_bootstrap_prefix)"
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
                _koopa_warn "koopa bootstrap is out of date: \
${dict['installed_version']} != ${dict['expected_version']}."
                _koopa_warn "Run 'koopa install user bootstrap' to update."
                bool['warnings']=1
            fi
        else
            _koopa_warn 'koopa bootstrap is out of date.'
            _koopa_warn "Run 'koopa install user bootstrap' to update."
            bool['warnings']=1
        fi
    fi
    if _koopa_is_macos
    then
        dict['expected_r_version']="$( \
            _koopa_app_json_version 'r' \
        )"
        local r_bin
        for r_bin in \
            '/usr/local/bin/R' \
            '/Library/Frameworks/R.framework/Resources/bin/R'
        do
            [[ -x "$r_bin" ]] || continue
            dict['installed_r_version']="$( \
                _koopa_r_version "$r_bin" \
            )"
            if [[ "${dict['installed_r_version']}" \
                != "${dict['expected_r_version']}" ]]
            then
                _koopa_warn "System R is out of date at '${r_bin}': \
${dict['installed_r_version']} != ${dict['expected_r_version']}."
                bool['warnings']=1
            fi
        done
        dict['py_maj_min_ver']="$( \
            _koopa_python_major_minor_version \
        )"
        dict['expected_python_version']="$( \
            _koopa_app_json_version \
                "python${dict['py_maj_min_ver']}" \
        )"
        local python_bin
        for python_bin in \
            '/usr/local/bin/python3' \
            '/Library/Frameworks/Python.framework/Versions/Current/bin/python3'
        do
            [[ -x "$python_bin" ]] || continue
            dict['installed_python_version']="$( \
                _koopa_get_version "$python_bin" \
            )"
            if [[ "${dict['installed_python_version']}" \
                != "${dict['expected_python_version']}" ]]
            then
                _koopa_warn "System Python is out of date \
at '${python_bin}': ${dict['installed_python_version']} \
!= ${dict['expected_python_version']}."
                bool['warnings']=1
            fi
        done
    fi
    "${KOOPA_PREFIX:?}/bin/koopa" internal check-system
    _koopa_check_disk '/'
    # > _koopa_check_exports
    if [[ "${bool['warnings']}" -eq 1 ]]
    then
        _koopa_warn 'System checks completed with warnings.'
        return 1
    fi
    _koopa_alert_success 'System passed all checks.'
    return 0
}
