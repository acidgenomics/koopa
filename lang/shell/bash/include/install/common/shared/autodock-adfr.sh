#!/usr/bin/env bash

main() {
    # """
    # Install ADFR suite.
    # @note Updated 2022-10-19.
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
    local app dict
    koopa_assert_has_no_args "$#"
    declare -A app
    app['yes']="$(koopa_locate_yes)"
    [[ -x "${app['yes']}" ]] || return 1
    declare -A dict=(
        ['arch']="$(koopa_arch)" # e.g. 'x86_64'.
        ['name']='ADFRsuite'
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    dict['libexec']="$(koopa_init_dir "${dict['prefix']}/libexec")"
    if koopa_is_macos
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
            koopa_stop 'Unsupported version.'
            ;;
    esac
    dict['bn']="${dict['name']}_${dict['arch']}${dict['platform']}\
_${dict['version']}"
    dict['file']="${dict['bn']}.tar.gz"
    dict['url']="https://ccsb.scripps.edu/adfr/download/${dict['id']}/"
    koopa_download "${dict['url']}" "${dict['file']}"
    koopa_extract "${dict['file']}"
    koopa_cd "${dict['bn']}"
    koopa_print_env
    # Install script options:
    # * -d: Target directory.
    # * -c: How to compile the Python files. Use 0 for .pyc or 1 for .pyo.
    # NOTE Installer currently fails unless we include 'true' catch here.
    "${app['yes']}" | ./install.sh -d "${dict['libexec']}" -c 0 || true
    (
        koopa_cd "${dict['prefix']}"
        koopa_ln 'libexec/bin' 'bin'
    )
    koopa_alert_note "The molecular surface calculation software (MSMS) is \
freely available for academic research. For obtaining commercial license \
usage, contact Dr. Sanner at sanner@scripps.edu."
    return 0
}
