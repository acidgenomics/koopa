#!/usr/bin/env bash

koopa::configure_rust() { # {{{1
    # """
    # Configure Rust.
    # @note Updated 2021-06-13.
    # """
    local name name_fancy prefix version
    version="${1:-}"
    [[ -z "$version" ]] && version='rolling'
    name='rust'
    name_fancy='Rust'
    prefix="$(koopa::rust_packages_prefix "$version")"
    koopa::configure_start "$name_fancy" "$prefix"
    koopa::sys_mkdir "$prefix"
    koopa::sys_set_permissions "$(koopa::dirname "$prefix")"
    koopa::link_into_opt "$prefix" "${name}-packages"
    koopa::configure_success "$name_fancy" "$prefix"
}

koopa::install_rust() { # {{{1
    koopa::install_app \
        --name-fancy='Rust' \
        --name='rust' \
        --no-link \
        --version='rolling' \
        "$@"
}

koopa:::install_rust() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2021-06-13.
    # """
    local file pkg_prefix prefix url version
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    pkg_prefix="$(koopa::rust_packages_prefix "$version")"
    RUSTUP_HOME="$prefix"
    CARGO_HOME="$pkg_prefix"
    export CARGO_HOME RUSTUP_HOME
    koopa::dl \
        'RUSTUP_HOME' "$RUSTUP_HOME" \
        'CARGO_HOME' "$CARGO_HOME"
    koopa::configure_rust "$version"
    koopa::sys_mkdir "$prefix"
    url='https://sh.rustup.rs'
    file='rustup.sh'
    koopa::download "$url" "$file"
    koopa::chmod +x "$file"
    # Can get the version of install script with '--version' here.
    "./${file}" --no-modify-path -v -y
    koopa::sys_set_permissions -r "$pkg_prefix"
    return 0
}

koopa::uninstall_rust() { # {{{1
    koopa::uninstall_app \
        --name-fancy='Rust' \
        --name='rust' \
        --no-link \
        "$@"
}

koopa::update_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2021-05-25.
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
        koopa::alert_note "${name_fancy} is up-to-date."
        return 0
    fi
    koopa::activate_rust
    koopa::assert_is_installed 'rustup'
    koopa::h1 'Updating Rust via rustup.'
    export RUST_BACKTRACE='full'
    # rustup v1.21.0 fix.
    # https://github.com/rust-lang/rustup/issues/2166
    koopa::mkdir "${RUSTUP_HOME:?}/downloads"
    # rustup v1.21.1 fix (2020-01-31).
    koopa::rm "${CARGO_HOME:?}/bin/"{'cargo-fmt','rustfmt'}
    # > rustup update stable
    rustup update
    koopa::sys_set_permissions -r "${CARGO_HOME:?}"
    koopa::update_success "$name_fancy"
    return 0
}
