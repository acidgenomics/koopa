#!/usr/bin/env bash

koopa::install_rust_packages() { # {{{1
    koopa::install_app_packages \
        --name-fancy='Rust' \
        --name='rust' \
        "$@"
}

koopa:::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2021-09-22.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local args cargo default jobs pkg pkgs pkg_args root rustc version
    koopa::configure_rust
    koopa::activate_rust
    export RUST_BACKTRACE=1
    cargo="$(koopa::locate_cargo)"
    rustc="$(koopa::locate_rustc)"
    koopa::add_to_path_start "$(koopa::dirname "$rustc")"
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
            'cargo-outdated'
            'cargo-update'
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
            'ripgrep-all')
                pkg='ripgrep_all'
                ;;
        esac
        "$cargo" install "$pkg" "${args[@]}"
    done
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
    koopa::update_app \
        --name-fancy='Rust packages' \
        --name='rust-packages' \
        "$@"
}

koopa:::update_rust_packages() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2021-10-05.
    # @seealso
    # - https://crates.io/crates/cargo-update
    # - https://github.com/nabijaczleweli/cargo-update
    # """
    local cargo
    koopa::configure_rust
    koopa::activate_rust
    export RUST_BACKTRACE=1
    cargo="$(koopa::locate_cargo)"
    koopa::add_to_path_start "$(koopa::dirname "$cargo")"
    "$cargo" install-update -a
    return 0
}
