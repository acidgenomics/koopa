#!/usr/bin/env bash

koopa::python_venv_create() { # {{{1
    # """
    # Create Python virtual environment.
    # @note Updated 2022-01-20.
    # """
    local app default_pkgs dict pos
    koopa::assert_has_args "$#"
    koopa::assert_has_no_envs
    declare -A app=(
        [python]="$(koopa::locate_python)"
    )
    declare -A dict=(
        [name]=''
        [name_fancy]='Python virtual environment'
        [reinstall]=0
    )
    default_pkgs=('pip' 'setuptools' 'wheel')
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key-value pairs --------------------------------------------------
            '--name='*)
                dict[name]="${1#*=}"
                shift 1
                ;;
            '--name')
                dict[name]="${2:?}"
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
            # Flags ------------------------------------------------------------
            '--force' | \
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
    koopa::assert_is_set \
        --name "${dict[name]}" \
        --python "${app[python]}"
    koopa::assert_is_installed "${app[python]}"
    dict[prefix]="$(koopa::python_venv_prefix)/${dict[name]}"
    if [[ "${dict[reinstall]}" -eq 1 ]]
    then
        koopa::sys_rm "${dict[prefix]}"
    fi
    if [[ -d "${dict[prefix]}" ]]
    then
        koopa::alert_note "Environment already exists at '${dict[prefix]}'."
        return 0
    fi
    koopa::alert_install_start "${dict[name_fancy]}" "${dict[prefix]}"
    koopa::sys_mkdir "${dict[prefix]}"
    "${app[python]}" -m venv "${dict[prefix]}"
    app[venv_python]="${dict[prefix]}/bin/python3"
    koopa::assert_is_installed "${app[venv_python]}"
    "${app[venv_python]}" -m pip install --upgrade "${default_pkgs[@]}"
    if [[ "$#" -gt 0 ]]
    then
        "${app[venv_python]}" -m pip install --upgrade "$@"
    fi
    koopa::sys_set_permissions --recursive "${dict[prefix]}"
    "${app[venv_python]}" -m pip list
    koopa::alert_install_success "${dict[name_fancy]}" "${dict[prefix]}"
    return 0
}
