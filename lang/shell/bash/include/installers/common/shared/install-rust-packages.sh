#!/usr/bin/env bash

main() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2022-04-09.
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
    koopa_assert_has_no_args "$#"
    koopa_activate_opt_prefix 'openssl' 'rust'
    declare -A app
    declare -A dict=(
        [jobs]="$(koopa_cpu_count)"
        [opt_prefix]="$(koopa_opt_prefix)"
        [root]="${INSTALL_PREFIX:?}"
    )
    dict[rust_prefix]="${dict[opt_prefix]}/rust"
    dict[cargo_home]="${dict[rust_prefix]}"
    dict[rustup_home]="${dict[rust_prefix]}/rustup"
    app[cargo]="${dict[cargo_home]}/bin/cargo"
    app[rustc]="${dict[cargo_home]}/bin/rustc"
    koopa_mkdir "${dict[root]}/bin"
    koopa_add_to_path_start "${dict[root]}/bin"
    CARGO_HOME="${dict[cargo_home]}"
    RUSTUP_HOME="${dict[rustup_home]}"
    export CARGO_HOME RUSTUP_HOME
    export OPENSSL_DIR="${dict[opt_prefix]}/openssl"
    export RUST_BACKTRACE=1
    pkgs=(
        # > 'ripgrep-all'
        'bat'
        'broot'
        'cargo-outdated'
        'cargo-update'
        'difftastic'
        'dog'
        'du-dust'
        'exa'
        'fd-find'
        'hyperfine'
        'mcfly'
        'procs'
        'ripgrep'
        'starship'
        'tealdeer'
        'tokei'
        'xsv'
        'zoxide'
    )
    koopa_dl 'Packages' "$(koopa_to_string "${pkgs[@]}")"
    # Can use '--force' flag here to force reinstall.
    pkg_args=(
        '--jobs' "${dict[jobs]}"
        '--root' "${dict[root]}"
        '--verbose'
    )
    for pkg in "${pkgs[@]}"
    do
        local args version
        args=("${pkg_args[@]}")
        version="$(koopa_variable "rust-${pkg}")"
        # Edge case handling of name variants on crates.io.
        case "$pkg" in
            'ripgrep-all')
                pkg='ripgrep_all'
                ;;
        esac
        args+=("$pkg")
        case "$pkg" in
            'dog')
                args+=(
                    '--git' 'https://github.com/ogham/dog.git'
                    '--tag' "v${version}"
                )
                ;;
            'du-dust')
                # Currently outdated on crates.io.
                args+=(
                    '--git' 'https://github.com/bootandy/dust.git'
                    '--tag' "v${version}"
                )
                ;;
            'fd-find')
                # Currently outdated on crates.io.
                args+=(
                    '--git' 'https://github.com/sharkdp/fd.git'
                    '--tag' "v${version}"
                )
                ;;
            'mcfly')
                # Currently only available on GitHub.
                args+=(
                    '--git' 'https://github.com/cantino/mcfly.git'
                    '--tag' "v${version}"
                )
                ;;
            'ripgrep_all')
                # Current v0.9.6 stable doesn't build on Linux.
                # https://github.com/phiresky/ripgrep-all/issues/88
                args+=(
                    '--git' 'https://github.com/phiresky/ripgrep-all'
                )
                ;;
            *)
                # Packages available on crates.io.
                args+=('--version' "${version}")
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
