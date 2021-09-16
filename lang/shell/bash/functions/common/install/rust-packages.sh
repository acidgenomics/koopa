#!/usr/bin/env bash

koopa::install_rust_packages() {
    koopa:::install_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        --no-link \
        --no-prefix-check \
        --prefix="$(koopa::rust_packages_prefix)" \
        "$@"
}

koopa:::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2021-09-15.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local args default jobs pkg pkgs pkg_args root version
    koopa::assert_has_no_envs
    koopa::configure_rust
    koopa::activate_rust
    # NOTE This step will currently fail when '--reinstall' is set.
    # These packages are installed by default in our Rust install script.
    koopa::assert_is_installed 'cargo' 'rustc' 'rustup'
    pkgs=("$@")
    root="${INSTALL_PREFIX:?}"
    jobs="$(koopa::cpu_count)"
    default=0
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        default=1
        pkgs=(
            # Currently failing to build due to cachedir constraint.
            # https://github.com/phiresky/ripgrep-all/issues/88
            # > 'ripgrep-all'
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'procs'
            'ripgrep'
            'starship'
            'tokei'
            'xsv'
            'zoxide'
        )
    fi
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    # Can use '--force' flag here to force reinstall.
    pkg_args=(
        '--jobs' "$jobs"
        '--root' "$root"
        '--verbose'
    )
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
    return 0
}

koopa::uninstall_rust_packages() { # {{{1
    # """
    # Uninstall Rust packages.
    # @note Updated 2021-06-14.
    # """
    koopa:::uninstall_app \
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
