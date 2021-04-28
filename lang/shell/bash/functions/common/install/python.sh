#!/usr/bin/env bash

koopa::install_python_packages() { # {{{1
    # """
    # Install Python packages.
    # @note Updated 2021-04-28.
    # """
    local install_flags name_fancy pkg pkg_lower pkgs pos python version
    name_fancy='Python packages'
    python="$(koopa::python)"
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --reinstall)
                reinstall=1
                shift 1
                ;;
            '')
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_no_envs
    koopa::assert_is_installed "$python"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        pkgs=(
            # > 'pynvim'
            'pip2pi'
            'psutil'
            'pyflakes'
            'pytaglib'
            'pytest'
            'setuptools'
            'six'
            'wheel'
        )
        if ! koopa::is_installed brew
        then
            pkgs+=(
                'black'
                'bpytop'
                'flake8'
                'pipx'
                'pylint'
                'ranger-fm'
            )
        fi
        for i in "${!pkgs[@]}"
        do
            pkg="${pkgs[$i]}"
            pkg_lower="$(koopa::lowercase "$pkg")"
            version="$(koopa::variable "python-${pkg_lower}")"
            pkgs[$i]="${pkg}==${version}"
        done
    fi
    koopa::install_start "$name_fancy"
    install_flags=("--python=${python}")
    [[ "$reinstall" -eq 1 ]] && install_flags+=('--reinstall')
    koopa::python_add_site_packages_to_sys_path "$python"
    koopa::pip_install "${install_flags[@]}" "${pkgs[@]}"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::update_python_packages() { # {{{1
    # """
    # Update all pip packages.
    # @note Updated 2020-11-19.
    # @seealso
    # - https://github.com/pypa/pip/issues/59
    # - https://stackoverflow.com/questions/2720014
    # """
    local name_fancy pkgs prefix python x
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    python="$(koopa::python)"
    koopa::is_installed "$python" || return 0
    name_fancy='Python packages'
    koopa::install_start "$name_fancy"
    # FIXME MAKE THIS A FUNCTION.
    x="$("$python" -m pip list --outdated --format='freeze')"
    x="$(koopa::print "$x" | grep -v '^\-e')"
    if [[ -z "$x" ]]
    then
        koopa::alert_success 'All Python packages are current.'
        return 0
    fi
    prefix="$(koopa::python_site_packages_prefix)"
    readarray -t pkgs <<< "$(koopa::print "$x" | cut -d '=' -f 1)"
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    koopa::dl 'Prefix' "$prefix"
    "$python" -m pip install --no-warn-script-location --upgrade "${pkgs[@]}"
    koopa::is_symlinked_app "$python" && koopa::link_app python
    koopa::install_success "$name_fancy"
    return 0
}
