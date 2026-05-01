#!/usr/bin/env bash

main() {
    # """
    # Install ADFR suite.
    # @note Updated 2023-06-01.
    #
    # Linux:
    # - ADFRsuite_x86_64Linux_1.0.tar.gz
    # - https://ccsb.scripps.edu/adfr/download/1038/
    # macOS:
    # - ADFRsuite_x86_64Darwin_1.0.tar.gz
    # - https://ccsb.scripps.edu/adfr/download/1033/
    # 
    # @seealso
    # - https://ccsb.scripps.edu/adfr/downloads/
    # """
    local -A app dict
    app['yes']="$(_koopa_locate_yes)"
    _koopa_assert_is_executable "${app[@]}"
    dict['arch']="$(_koopa_arch)" # e.g. 'x86_64'.
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    dict['libexec']="$(_koopa_init_dir "${dict['prefix']}/libexec")"
    if _koopa_is_macos
    then
        dict['platform']='Darwin'
    else
        dict['platform']='Linux'
    fi
    case "${dict['version']}" in
        '1.0')
            case "${dict['platform']}" in
                'Darwin')
                    dict['id']='1033'
                    ;;
                'Linux')
                    dict['id']='1038'
                    ;;
            esac
            ;;
        *)
            _koopa_stop 'Unsupported version.'
            ;;
    esac
    dict['file']="adfr.tar.gz"
    dict['url']="https://ccsb.scripps.edu/adfr/download/${dict['id']}/"
    _koopa_download "${dict['url']}" "${dict['file']}"
    _koopa_extract "${dict['file']}" 'src'
    _koopa_cd 'src'
    _koopa_print_env
    # Install script options:
    # * -d: Target directory.
    # * -c: How to compile the Python files. Use 0 for .pyc or 1 for .pyo.
    # NOTE Installer currently fails unless we include 'true' catch here.
    "${app['yes']}" | ./install.sh -d "${dict['libexec']}" -c 0 || true
    (
        _koopa_cd "${dict['prefix']}"
        _koopa_ln 'libexec/bin' 'bin'
    )
    _koopa_alert_note "The molecular surface calculation software (MSMS) is \
freely available for academic research. For obtaining commercial license \
usage, contact Dr. Sanner at sanner@scripps.edu."
    return 0
}
