#!/usr/bin/env bash

# FIXME MOVE THIS TO UPDATE SECTION.

koopa::update_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2020-11-17.
    # """
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
    [[ "$force" -eq 0 ]] && koopa::is_current_version rust && return 0
    if ! koopa::is_installed rustup
    then
        koopa::note 'rustup is not installed.'
        return 0
    fi
    koopa::h1 'Updating Rust via rustup.'
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    koopa::mkdir "${RUSTUP_HOME}/downloads"
    # rustup v1.21.1 fix (2020-01-31).
    koopa::rm "${CARGO_HOME}/bin/"{'cargo-fmt','rustfmt'}
    # > rustup update stable
    rustup update
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
