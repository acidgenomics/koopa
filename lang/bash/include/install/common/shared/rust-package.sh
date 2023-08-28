#!/usr/bin/env bash

# FIXME Need to split out package-specific configuration.

main() {
    # """
    # Install Rust package.
    # @note Updated 2023-08-28.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # @seealso
    # Setting custom linker arguments using RUSTFLAGS:
    # - https://doc.rust-lang.org/cargo/reference/environment-variables.html#
    #     environment-variables-cargo-reads
    # - https://internals.rust-lang.org/t/compiling-rustc-with-non-standard-
    #     flags/8950/6
    # - https://github.com/rust-lang/cargo/issues/5077
    # - https://news.ycombinator.com/item?id=29570931
    # """
    local -A app dict
    local -a install_args
    koopa_activate_app --build-only 'rust'
    app['cargo']="$(koopa_locate_cargo)"
    koopa_assert_is_executable "${app[@]}"
    dict['cargo_home']="$(koopa_init_dir 'cargo')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:?}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:?}"
    dict['version']="${KOOPA_INSTALL_VERSION:?}"
    koopa_assert_is_dir "${dict['cargo_home']}"
    export RUST_BACKTRACE='full' # or '1'.
    if [[ -n "${LDFLAGS:-}" ]]
    then
        local -a ldflags rustflags
        local ldflag
        rustflags=()
        IFS=' ' read -r -a ldflags <<< "${LDFLAGS:?}"
        for ldflag in "${ldflags[@]}"
        do
            rustflags+=('-C' "link-arg=${ldflag}")
        done
        export RUSTFLAGS="${rustflags[*]}"
    fi
    install_args=(
        '--config' 'net.git-fetch-with-cli=true'
        '--config' 'net.retry=5'
        '--jobs' "${dict['jobs']}"
        '--locked'
        '--root' "${dict['prefix']}"
        '--verbose'
    )
    # Edge case handling of name variants on crates.io.
    case "${dict['name']}" in
        'delta')
            dict['cargo_name']='git-delta'
            ;;
        'nushell')
            dict['cargo_name']='nu'
            ;;
        'ripgrep-all')
            dict['cargo_name']='ripgrep_all'
            ;;
        *)
            dict['cargo_name']="${dict['name']}"
            ;;
    esac
    install_args+=("${dict['cargo_name']}")
    case "${dict['name']}" in
        'broot')
            install_args+=(
                '--git' 'https://github.com/Canop/broot.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        'dog')
            install_args+=(
                '--git' 'https://github.com/ogham/dog.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        'du-dust')
            install_args+=(
                '--git' 'https://github.com/bootandy/dust.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        'fd-find')
            install_args+=(
                '--git' 'https://github.com/sharkdp/fd.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        'lsd')
            install_args+=(
                '--git' 'https://github.com/lsd-rs/lsd.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        'ripgrep-all')
            install_args+=(
                '--git' 'https://github.com/phiresky/ripgrep-all.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        'starship')
            install_args+=(
                '--git' 'https://github.com/starship/starship.git'
                '--tag' "v${dict['version']}"
            )
            ;;
        *)
            # Packages available on crates.io.
            install_args+=('--version' "${dict['version']}")
            ;;
    esac
    case "${dict['name']}" in
        'nushell')
            install_args+=('--features' 'extra')
            ;;
        'ripgrep')
            install_args+=('--features' 'pcre2')
            ;;
        'tuc')
            install_args+=('--features' 'regex')
            ;;
    esac
    export CARGO_HOME="${dict['cargo_home']}"
    koopa_print_env
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}
