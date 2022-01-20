#!/usr/bin/env bash

koopa::python_pip_install() { # {{{1
    # """
    # Internal pip install command.
    # @note Updated 2021-11-11.
    #
    # Usage of '--target' with '--upgrade' will remove existing bin files from
    # other packages that are not updated. This is annoying, but there's no
    # current workaround except to not use '--upgrade'.
    #
    # If you disable '--upgrade', then these warning messages will pop up:
    # > WARNING: Target directory XXX already exists.
    # > Specify --upgrade to force replacement.
    #
    # @seealso
    # - https://pip.pypa.io/en/stable/cli/pip_install/
    # - https://docs.python-guide.org/dev/pip-virtualenv/
    # - https://github.com/pypa/pip/issues/3828
    # - https://github.com/pypa/pip/issues/8063
    # """
    local app dict pkgs pos
    koopa::assert_has_args "$#"
    declare -A app=(
        [python]="$(koopa::locate_python)"
    )
    declare -A dict=(
        [reinstall]=0
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--python='*)
                app[python]="${1#*=}"
                shift 1
                ;;
            '--python')
                app[python]="${2:?}"
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--reinstall')
                dict[reinstall]=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            '-'*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    pkgs=("$@")
    koopa::configure_python "${app[python]}"
    dict[version]="$(koopa::get_version "${app[python]}")"
    dict[target]="$(koopa::python_packages_prefix "${dict[version]}")"
    koopa::dl \
        'Python' "${app[python]}" \
        'Packages' "$(koopa::to_string "${pkgs[*]}")" \
        'Target' "${dict[target]}"
    # See also rules defined in '~/.config/pip/pip.conf'.
    install_args=(
        "--target=${dict[target]}"
        '--disable-pip-version-check'
        '--no-warn-script-location'
        '--progress-bar=pretty'
        '--upgrade'
    )
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        pip_flags+=(
            '--force-reinstall'
            '--ignore-installed'
        )
    fi
    export PIP_REQUIRE_VIRTUALENV='false'
    # The pip '--isolated' flag ignores the user 'pip.conf' file.
    "${app[python]}" -m pip --isolated install "${install_args[@]}" "${pkgs[@]}"
    return 0
}
