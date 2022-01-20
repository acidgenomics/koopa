#!/usr/bin/env bash

koopa::configure_dotfiles() { # {{{1
    # """
    # Configure dotfiles.
    # @note Updated 2022-01-19.
    # """
    local app dict
    koopa::assert_has_args_le "$#" 1
    declare -A app=(
        [bash]="$(koopa::locate_bash)"
    )
    declare -A dict=(
        [name]='dotfiles'
        [prefix]="${1:-}"
    )
    [[ -z "${dict[prefix]}" ]] && dict[prefix]="$(koopa::dotfiles_prefix)"
    koopa::assert_is_dir "${dict[prefix]}"
    dict[script]="${dict[prefix]}/install"
    koopa::assert_is_file "${dict[script]}"
    koopa::add_koopa_config_link "${dict[prefix]}" "${dict[name]}"
    koopa::add_to_path_start "$(koopa::dirname "${app[bash]}")"
    "${app[bash]}" "${dict[script]}"
    return 0
}

koopa::configure_go() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Go' \
        --name='go' \
        --which-app="$(koopa::locate_go)" \
        "$@"
}

koopa::configure_julia() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Julia' \
        --name='julia' \
        --which-app="$(koopa::locate_julia)" \
        "$@"
}

koopa::configure_nim() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Nim' \
        --name='nim' \
        --which-app="$(koopa::locate_nim)" \
        "$@"
}

koopa::configure_node() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Node.js' \
        --name='node' \
        --which-app="$(koopa::locate_node)" \
        "$@"
}

koopa::configure_python() { #{{{1
    # """
    # Configure Python.
    # @note Updated 2021-11-30.
    #
    # This creates a Python 'site-packages' directory and then links using
    # a 'koopa.pth' file into the Python system 'site-packages'.
    #
    # @seealso
    # > "$python" -m site
    # """
    local app dict
    declare -A app=(
        [python]="${1:-}"
    )
    if [[ -z "${app[python]}" ]]
    then
        app[python]="$(koopa::locate_python)"
    fi
    koopa::assert_is_installed "${app[python]}"
    declare -A dict=(
        [version]="$(koopa::get_version "${app[python]}")"
    )
    dict[sys_site_pkgs]="$( \
        koopa::python_system_packages_prefix "${app[python]}" \
    )"
    # FIXME Rework this, passing in Python directly instead.
    dict[k_site_pkgs]="$(koopa::python_packages_prefix "${dict[version]}")"
    dict[pth_file]="${dict[sys_site_pkgs]}/koopa.pth"
    koopa::alert "Adding '${dict[pth_file]}' path file."
    if koopa::is_koopa_app "${app[python]}"
    then
        app[write_string]='koopa::write_string'
    else
        app[write_string]='koopa::sudo_write_string'
    fi
    "${app[write_string]}" "${dict[k_site_pkgs]}" "${dict[pth_file]}"
    koopa::configure_app_packages \
        --name-fancy='Python' \
        --name='python' \
        --prefix="${dict[k_site_pkgs]}"
    return 0
}

koopa::configure_ruby() { # {{{1
    koopa::configure_app_packages \
        --name-fancy='Ruby' \
        --name='ruby' \
        --which-app="$(koopa::locate_ruby)" \
        "$@"
    koopa::rm "${HOME}/.gem"
    return 0
}

koopa::configure_rust() { # {{{1
    # """
    # Configure Rust.
    # @note Updated 2021-09-17.
    # """
    koopa::configure_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        --version='rolling' \
        "$@"
}
