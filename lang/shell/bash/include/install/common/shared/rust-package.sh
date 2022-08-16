#!/usr/bin/env bash

main() {
    # """
    # Install Rust packages.
    # @note Updated 2022-08-16.
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
    # @seealso
    # - https://github.com/Homebrew/homebrew-core/blob/master/Formula/ripgrep.rb
    # """
    local app dict install_args
    koopa_assert_has_no_args "$#"
    koopa_activate_build_opt_prefix \
        'pkg-config' \
        'rust'
    declare -A app=(
        [cargo]="$(koopa_locate_cargo)"
    )
    [[ -x "${app[cargo]}" ]] || return 1
    declare -A dict=(
        [cargo_home]="$(koopa_init_dir 'cargo')"
        [jobs]="$(koopa_cpu_count)"
        [name]="${INSTALL_NAME:?}"
        [prefix]="${INSTALL_PREFIX:?}"
        [version]="${INSTALL_VERSION:?}"
    )
    export RUST_BACKTRACE='full' # or '1'.
    install_args=(
        '--jobs' "${dict[jobs]}"
        '--locked'
        '--root' "${dict[prefix]}"
        '--verbose'
    )
    # Edge case handling of name variants on crates.io.
    case "${dict[name]}" in
        'delta')
            dict[cargo_name]='git-delta'
            ;;
        'ripgrep-all')
            dict[cargo_name]='ripgrep_all'
            ;;
        *)
            dict[cargo_name]="${dict[name]}"
            ;;
    esac
    install_args+=("${dict[cargo_name]}")
    case "${dict[name]}" in
        'dog')
            # Current 0.1.0 crate on crates.io fails with Rust 1.61.
            install_args+=(
                '--git' 'https://github.com/ogham/dog.git'
                '--tag' "v${dict[version]}"
            )
            ;;
        'ripgrep-all')
            # Current v0.9.6 stable doesn't build on Linux.
            # https://github.com/phiresky/ripgrep-all/issues/88
            install_args+=(
                '--git' 'https://github.com/phiresky/ripgrep-all'
            )
            ;;
        # > 'du-dust')
        # >     # Currently outdated on crates.io.
        # >     install_args+=(
        # >         '--git' 'https://github.com/bootandy/dust.git'
        # >         '--tag' "v${dict[version]}"
        # >     )
        # >     ;;
        # > 'exa')
        # >     # Current 0.10.1 crate on crates.io fails with Rust 1.61.
        # >     install_args+=(
        # >         '--git' 'https://github.com/ogham/exa.git'
        # >         '--tag' "v${dict[version]}"
        # >     )
        # >     ;;
        # > 'fd-find')
        # >     # Currently outdated on crates.io.
        # >     install_args+=(
        # >         '--git' 'https://github.com/sharkdp/fd.git'
        # >         '--tag' "v${dict[version]}"
        # >     )
        # >     ;;
        # > 'mcfly')
        # >     # Currently only available on GitHub.
        # >     install_args+=(
        # >         '--git' 'https://github.com/cantino/mcfly.git'
        # >         '--tag' "v${dict[version]}"
        # >     )
        # >     ;;
        *)
            # Packages available on crates.io.
            install_args+=('--version' "${dict[version]}")
            case "${dict[name]}" in
                'ripgrep')
                    install_args+=('--features' 'pcre2')
                    ;;
                'tuc')
                    install_args+=('--features' 'regex')
                    ;;
            esac
            ;;
    esac
    export CARGO_HOME="${dict[cargo_home]}"
    "${app[cargo]}" install "${install_args[@]}"
    return 0
}
