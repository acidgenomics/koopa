#!/usr/bin/env bash

koopa::update_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2020-12-31.
    # """
    local force name_fancy
    koopa::assert_has_no_envs
    force=0
    name_fancy='Rust'
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
    if [[ "$force" -eq 0 ]] && koopa::is_current_version rust
    then
        koopa::note "${name_fancy} is up-to-date."
        return 0
    fi
    koopa::assert_is_installed rustup
    koopa::h1 'Updating Rust via rustup.'
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    koopa::mkdir "${RUSTUP_HOME}/downloads"
    # rustup v1.21.1 fix (2020-01-31).
    koopa::rm "${CARGO_HOME}/bin/"{'cargo-fmt','rustfmt'}
    # > rustup update stable
    rustup update
    koopa::update_success "$name_fancy"
    return 0
}

koopa::update_rust_packages() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2020-07-17.
    # """
    koopa::install_rust_packages "$@"
    return 0
}
