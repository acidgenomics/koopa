#!/usr/bin/env bash

main() {
    # """
    # Install Rust packages.
    # @note Updated 2023-02-10.
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
    koopa_activate_app --build-only \
        'git' \
        'pkg-config' \
        'rust'
    declare -A app
    app['cargo']="$(koopa_locate_cargo)"
    [[ -x "${app['cargo']}" ]] || return 1
    declare -A dict=(
        ['cargo_home']="$(koopa_init_dir 'cargo')"
        ['jobs']="$(koopa_cpu_count)"
        ['name']="${KOOPA_INSTALL_NAME:?}"
        ['prefix']="${KOOPA_INSTALL_PREFIX:?}"
        ['version']="${KOOPA_INSTALL_VERSION:?}"
    )
    koopa_assert_is_dir "${dict['cargo_home']}"
    export RUST_BACKTRACE='full' # or '1'.
    install_args=(
        '--config' 'net.git-fetch-with-cli=true'
        '--config' 'net.retry=5'
        '--jobs' "${dict['jobs']}"
        '--locked'
        '--root' "${dict['prefix']}"
        '--verbose'
    )
    # Enable OpenSSL for specific apps. Note that usage of OpenSSL 3 currently
    # results in build issues.
    case "${dict['name']}" in
        'dog' | \
        'mdcat')
            koopa_activate_app 'openssl1'
            dict['openssl']="$(koopa_app_prefix 'openssl1')"
            export OPENSSL_DIR="${dict['openssl']}"
            koopa_add_rpath_to_ldflags "${dict['openssl']}/lib"
            ;;
    esac
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
        'ripgrep-all')
            case "${dict['version']}" in
                '0.9.7')
                    dict['commit']='9e933ca7'
                    ;;
                *)
                    koopa_stop 'Unsupported version.'
                    ;;
            esac
            install_args+=(
                '--git' 'https://github.com/phiresky/ripgrep-all.git'
                '--rev' "${dict['commit']}"
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
