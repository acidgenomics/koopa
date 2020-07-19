#!/usr/bin/env bash

koopa::install_rust() { # {{{1
    local file name_fancy pos reinstall tmp_dir url
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
                reinstall=1
                shift 1
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    CARGO_HOME="$(koopa::rust_cargo_prefix)"
    export CARGO_HOME
    RUSTUP_HOME="$(koopa::rust_rustup_prefix)"
    export RUSTUP_HOME
    if [[ "$reinstall" -eq 1 ]]
    then
        koopa::sys_rm "$CARGO_HOME" "$RUSTUP_HOME"
    fi
    koopa::exit_if_dir "$CARGO_HOME" "$RUSTUP_HOME"
    name_fancy='Rust'
    koopa::install_start "$name_fancy"
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    koopa::assert_is_not_installed rustup-init
    koopa::dl 'CARGO_HOME' "$CARGO_HOME"
    koopa::dl 'RUSTUP_HOME' "$RUSTUP_HOME"
    koopa::mkdir "$CARGO_HOME" "$RUSTUP_HOME"
    tmp_dir="$(koopa::tmp_dir)"
    (
        url='https://sh.rustup.rs'
        file='rustup.sh'
        koopa::download "$url" "$file"
        chmod +x "$file"
        "./${file}" --no-modify-path -v -y
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$CARGO_HOME" "$RUSTUP_HOME"
    koopa::install_success "$name_fancy"
    koopa::restart
    return 0
}

koopa::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2020-07-10.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local crate crates name_fancy prefix
    koopa::assert_has_no_envs
    koopa::activate_rust
    koopa::exit_if_not_installed cargo rustc rustup
    name_fancy='Rust cargo crates'
    prefix="${CARGO_HOME:?}"
    koopa::install_start "$name_fancy" "$prefix"
    if [[ "$#" -eq 0 ]]
    then
        crates=(
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'ripgrep'
            'tokei'
            'xsv'
        )
    else
        crates=("$@")
    fi
    koopa::dl 'Crates' "$(koopa::to_string "${crates[@]}")"
    koopa::sys_set_permissions -ru "$prefix"
    for crate in "${crates[@]}"
    do
        cargo install "$crate"
    done
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

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

koopa::update_rust_packages() { # {{{1
    # """
    # Update Rust packages.
    # @note Updated 2020-07-17.
    # """
    koopa::install_rust_packages "$@"
    return 0
}
