#!/usr/bin/env bash

koopa_install_rust_package() {
    # """
    # Install Rust package.
    # @note Updated 2023-08-29.
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
    local -a install_args pos
    koopa_activate_app --build-only 'rust'
    app['cargo']="$(koopa_locate_cargo)"
    koopa_assert_is_executable "${app[@]}"
    dict['cargo_home']="$(koopa_init_dir 'cargo')"
    dict['cargo_name']=''
    dict['jobs']="$(koopa_cpu_count)"
    dict['name']="${KOOPA_INSTALL_NAME:-}"
    dict['prefix']="${KOOPA_INSTALL_PREFIX:-}"
    dict['version']="${KOOPA_INSTALL_VERSION:-}"
    pos=()
    while (("$#"))
    do
        case "$1" in
            # Key value pairs --------------------------------------------------
            '--cargo-name='*)
                dict['cargo_name']="${1#*=}"
                shift 1
                ;;
            '--cargo-name')
                dict['cargo_name']="${2:?}"
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
            # Other ------------------------------------------------------------
            *)
                koopa_invalid_arg "$1"
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_is_dir "${dict['cargo_home']}"
    [[ -z "${dict['cargo_name']}" ]] && dict['cargo_name']="${dict['name']}"
    export CARGO_HOME="${dict['cargo_home']}"
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
        '--version' "${dict['version']}"
    )
    [[ "$#" -gt 0 ]] && install_args+=("$@")
    install_args+=("${dict['cargo_name']}")
    koopa_print_env
    koopa_dl 'cargo install args' "${install_args[*]}"
    "${app['cargo']}" install "${install_args[@]}"
    return 0
}
