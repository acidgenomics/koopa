#!/usr/bin/env bash

koopa::update_rust() { # {{{1
    local force
    koopa::assert_has_no_envs
    force=0
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    koopa::assert_has_no_args "$#"
    [[ "$force" -eq 0 ]] && koopa::exit_if_current_version rust
    koopa::h1 'Updating Rust via rustup.'
    koopa::exit_if_not_installed rustup
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    mkdir -pv "${RUSTUP_HOME}/downloads"
    # rustup v1.21.1 fix (2020-01-31).
    rm -f "${CARGO_HOME}/bin/"{'cargo-fmt','rustfmt'}
    # > rustup update stable
    rustup update
    return 0
}
