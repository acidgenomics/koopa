#!/usr/bin/env bash

koopa_python_pip_install() {
    # """
    # Internal pip install command.
    # @note Updated 2023-05-16.
    #
    # The pip '--isolated' flag ignores the user 'pip.conf' file.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # - https://github.com/pypa/pip/issues/3828
    # - https://github.com/pypa/pip/issues/8063
    # - https://stackoverflow.com/a/43560499/3911732
    # """
    local -A app dict
    local -a dl_args pos
    koopa_assert_has_args "$#"
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--no-binary='*)
                pos=("$1")
                shift 1
                ;;
            '--no-binary')
                pos=("$1" "${2:?}")
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--python='*)
                app['python']="${1#*=}"
                shift 1
                ;;
            '--python')
                app['python']="${2:?}"
                shift 2
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ -z "${app['python']}" ]] && \
        app['python']="$(koopa_locate_python312 --realpath)"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    koopa_assert_is_executable "${app[@]}"
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        # Can enable this for more verbose logging.
        # > '-vvv'
        '--default-timeout=300'
        '--disable-pip-version-check'
        '--ignore-installed'
        '--no-cache-dir'
        '--no-warn-script-location'
        '--progress-bar=on'
        # > '--trusted-host=files.pythonhosted.org'
        # > '--trusted-host=pypi.org'
        # > '--trusted-host=pypi.python.org'
    )
    if [[ -n "${dict['prefix']}" ]]
    then
        install_args+=(
            "--target=${dict['prefix']}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict['prefix']}")
    fi
    install_args+=("$@")
    dl_args=(
        'python' "${app['python']}"
        'pip install args' "${install_args[*]}"
    )
    koopa_dl "${dl_args[@]}"
    # > unset -v PYTHONPATH
    export PIP_REQUIRE_VIRTUALENV='false'
    "${app['python']}" -m pip --isolated install "${install_args[@]}"
    return 0
}
