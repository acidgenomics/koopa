#!/usr/bin/env bash

koopa_python_pip_install() {
    # """
    # Internal pip install command.
    # @note Updated 2022-03-30.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # - https://github.com/pypa/pip/issues/3828
    # - https://github.com/pypa/pip/issues/8063
    # """
    local app dict dl_args pkgs pos
    koopa_assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa_locate_python)"
    )
    declare -A dict=(
        [prefix]=''
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--prefix='*)
                dict[prefix]="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict[prefix]="${2:?}"
                shift 2
                ;;
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
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
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args "$#"
    pkgs=("$@")
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        '--disable-pip-version-check'
        '--no-warn-script-location'
    )
    dl_args=(
        'Python' "${app[python]}"
        'Packages' "$(koopa_to_string "${pkgs[*]}")"
    )
    if [[ -n "${dict[prefix]}" ]]
    then
        install_args+=(
            "--target=${dict[prefix]}"
            '--upgrade'
        )
        dl_args+=('Target' "${dict[prefix]}")
    fi
    koopa_dl "${dl_args[@]}"
    # > unset -v PYTHONPATH
    export PIP_REQUIRE_VIRTUALENV='false'
    # The pip '--isolated' flag ignores the user 'pip.conf' file.
    "${app[python]}" -m pip --isolated \
        install "${install_args[@]}" "${pkgs[@]}"
    return 0
}
