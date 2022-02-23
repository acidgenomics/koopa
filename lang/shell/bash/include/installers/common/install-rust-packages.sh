#!/usr/bin/env bash

koopa:::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2022-02-23.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # @section Useful development packages (without binaries):
    #
    # - crossbeam
    # - hyper
    # - rayon
    # - tide
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
    koopa::activate_rust
    declare -A app=(
        [brew]="$(koopa::locate_brew 2>/dev/null || true)"
        [cargo]="$(koopa::locate_cargo)"
        [rustc]="$(koopa::locate_rustc)"
    )
    declare -A dict=(
        [jobs]="$(koopa::cpu_count)"
        [root]="${INSTALL_PREFIX:?}"
    )
    pkgs=(
        'cargo-outdated'
        'cargo-update'
    )
    if [[ ! -x "${app[brew]}" ]]
    then
        pkgs+=(
            # Currently failing to build due to cachedir constraint.
            # https://github.com/phiresky/ripgrep-all/issues/88
            # > 'ripgrep-all'
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'mcfly'
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
        # Edge case handling of name variants on crates.io.
        case "$pkg" in
            'ripgrep-all')
                pkg='ripgrep_all'
                ;;
        esac
        case "$pkg" in
            'du-dust')
                # Currently outdated on crates.io.
                args+=(
                    --git 'https://github.com/bootandy/dust.git'
                    --tag "v${version}"
                )
                ;;
            'fd-find')
                # Currently outdated on crates.io.
                args+=(
                    --git 'https://github.com/sharkdp/fd.git'
                    --tag "v${version}"
                )
                ;;
            'mcfly')
                # Currently only available on GitHub.
                args+=(
                    --git 'https://github.com/cantino/mcfly.git'
                    --tag "v${version}"
                )
                ;;
            *)
                # Packages available on crates.io.
                args+=(
                    "$pkg"
                    '--version' "${version}"
                )
                case "$pkg" in
                    'ripgrep')
                        args+=('--features' 'pcre2')
                        ;;
                esac
                ;;
        esac
        "${app[cargo]}" install "${args[@]}"
    done
    return 0
}
