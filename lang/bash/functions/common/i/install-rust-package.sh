#!/usr/bin/env bash

koopa_install_rust_package() {
    # """
    # Install Rust package.
    # @note Updated 2023-11-01.
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
    local -A app bool dict
    local -a install_args pos
    koopa_assert_is_install_subshell
    koopa_activate_app --build-only 'rust'
    app['cargo']="$(koopa_locate_cargo)"
    koopa_assert_is_executable "${app[@]}"
    bool['openssl']=0
    dict['cargo_home']="$(koopa_init_dir 'cargo')"
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--name='*)
                dict['name']="${1#*=}"
                shift 1
                ;;
            '--name')
                dict['name']="${2:?}"
                shift 2
                ;;
            '--prefix='*)
                dict['prefix']="${1#*=}"
                shift 1
                ;;
            '--prefix')
                dict['prefix']="${2:?}"
                shift 2
                ;;
            '--version='*)
                dict['version']="${1#*=}"
                shift 1
                ;;
            '--version')
                dict['version']="${2:?}"
                shift 2
                ;;
            # Passthrough key value pairs --------------------------------------
            '--features='* | \
            '--git='* | \
            '--tag='*)
                # e.g. '--features=extra'.
                # left-hand side: "${1%%=*}" (e.g. '--features').
                # right-hand side: "${1#*=}" (e.g. 'extra').
                pos+=("${1%%=*}" "${1#*=}")
                shift 1
                ;;
            '--features' | \
            '--git' | \
            '--tag')
                pos+=("$1" "$2")
                shift 2
                ;;
            # Flags ------------------------------------------------------------
            '--with-openssl')
                bool['openssl']=1
                shift 1
                ;;
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    koopa_assert_is_set \
        '--name' "${dict['name']}" \
        '--prefix' "${dict['prefix']}" \
        '--version' "${dict['version']}"
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_dir "${dict['cargo_home']}"
    export CARGO_HOME="${dict['cargo_home']}"
    export RUST_BACKTRACE='full' # or '1'.
    if [[ "${bool['openssl']}" -eq 1 ]]
    then
        koopa_activate_app 'openssl3'
        dict['openssl']="$(koopa_app_prefix 'openssl3')"
        export OPENSSL_DIR="${dict['openssl']}"
    fi
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
        '--version' "${dict['version']}"
    )
    [[ "$#" -gt 0 ]] && install_args+=("$@")
    install_args+=("${dict['name']}")
    # Ensure we put Rust package 'bin/' into PATH, to avoid installer warning.
    koopa_init_dir "${dict['prefix']}/bin"
    koopa_add_to_path_start "${dict['prefix']}/bin"
    koopa_print_env
    koopa_dl 'cargo install args' "${install_args[*]}"
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}
