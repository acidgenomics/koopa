#!/usr/bin/env bash

koopa::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2021-05-25.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local args default jobs name_fancy pkg pkgs pkg_args pos prefix
    local reinstall version
    name_fancy='Rust packages (cargo crates)'
    default=0
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --force|--reinstall)
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
    koopa::activate_rust
    if ! koopa::is_installed 'cargo' 'rustc' 'rustup'
    then
        koopa::alert_note 'Required: cargo, rustc, rustup.'
        return 0
    fi
    prefix="${CARGO_HOME:?}"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        default=1
        if koopa::is_installed 'brew'
        then
            koopa::alert_note 'Use Homebrew to manage Rust binaries instead.'
            return 0
        fi
        pkgs=(
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'procs'
            'ripgrep'
            # Currently failing to build due to cachedir constraint.
            # https://github.com/phiresky/ripgrep-all/issues/88
            # > 'ripgrep-all'
            'starship'
            'tokei'
            'xsv'
            'zoxide'
        )
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    koopa::sys_set_permissions -ru "$prefix"
    jobs="$(koopa::cpu_count)"
    pkg_args=(
        '--jobs' "${jobs}"
        '--verbose'
    )
    [[ "$reinstall" -eq 1 ]] && pkg_flags+=('--force')
    for pkg in "${pkgs[@]}"
    do
        args=("${pkg_args[@]}")
        if [[ "$default" -eq 1 ]]
        then
            version="$(koopa::variable "rust-${pkg}")"
            args+=('--version' "${version}")
        fi
        # Edge case handling for package name variants on crates.io.
        case "$pkg" in
            ripgrep-all)
                pkg='ripgrep_all'
                ;;
        esac
        cargo install "$pkg" "${args[@]}"
    done
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

koopa::uninstall_rust_packages() { # {{{1
    # """
    # Uninstall Rust packages.
    # @note Updated 2021-06-14.
    # """
    koopa::uninstall_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        --no-link \
        "$@"
}

koopa::update_rust_packages() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2020-07-17.
    # """
    koopa::install_rust_packages "$@"
    return 0
}
