#!/usr/bin/env bash

## FIXME The '--reinstall' flag doesn't seem to work correctly for this.

koopa:::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2022-01-26.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    #
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ripgrep.rb
    # """
    local app dict pkg pkgs pkg_args
    koopa::assert_has_no_args "$#"
    koopa::configure_rust
    koopa::activate_rust
    declare -A app=(
        [cargo]="$(koopa::locate_cargo)"
        [rustc]="$(koopa::locate_rustc)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [root]="${INSTALL_PREFIX:?}"
    )
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
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    # Can use '--force' flag here to force reinstall.
    pkg_args=(
        '--jobs' "${dict[jobs]}"
        '--root' "${dict[root]}"
        '--verbose'
    )
    koopa::add_to_path_start "$(koopa::dirname "${app[rustc]}")"
    export RUST_BACKTRACE=1
    for pkg in "${pkgs[@]}"
    do
        local args version
        args=("${pkg_args[@]}")
        version="$(koopa::variable "rust-${pkg}")"
        args+=('--version' "${version}")
        # Edge case handling for package name variants on crates.io.
        case "$pkg" in
            'ripgrep')
                args+=('--features' 'pcre2')
                ;;
            'ripgrep-all')
                pkg='ripgrep_all'
                ;;
        esac
        "${app[cargo]}" install "$pkg" "${args[@]}"
    done
    return 0
}
