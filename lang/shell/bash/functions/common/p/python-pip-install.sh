#!/usr/bin/env bash

koopa_python_pip_install() {
    # """
    # Internal pip install command.
    # @note Updated 2023-03-26.
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
    local app dict dl_args pkg pkgs pos
    koopa_assert_has_args "$#"
    local -A app dict
    dict['prefix']=''
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
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
        app['python']="$(koopa_locate_python311 --realpath)"
    [[ -x "${app['python']}" ]] || exit 1
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    pkgs=("$@")
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        '-vvv'
        '--default-timeout=300'
        '--disable-pip-version-check'
        '--ignore-installed'
        '--no-cache-dir'
        '--no-warn-script-location'
        '--progress-bar=on'
    )
    if [[ -n "${dict['prefix']}" ]]
    then
        install_args+=(
            "--target=${dict['prefix']}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict['prefix']}")
    fi
    # Disable binary wheels for some packages.
    for pkg in "${pkgs[@]}"
    do
        case "$pkg" in
            'pytaglib' | \
            'pytaglib=='*)
                local pkg_name
                app['cut']="$(koopa_locate_cut --allow-system)"
                [[ -x "${app['cut']}" ]] || exit 1
                pkg_name="$( \
                    koopa_print "$pkg" \
                    | "${app['cut']}" -d '=' -f 1 \
                )"
                install_args+=('--no-binary' "$pkg_name")
                ;;
        esac
    done
    install_args+=("${pkgs[@]}")
    dl_args=(
        'python' "${app['python']}"
        'pip install' "${install_args[*]}"
    )
    koopa_dl "${dl_args[@]}"
    # > unset -v PYTHONPATH
    export PIP_REQUIRE_VIRTUALENV='false'
    "${app['python']}" -m pip --isolated install "${install_args[@]}"
    return 0
}
