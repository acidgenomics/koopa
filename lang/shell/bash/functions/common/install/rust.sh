#!/usr/bin/env bash

koopa::install_rust() { # {{{1
    koopa::install_app \
        --name='rust' \
        --name-fancy='Rust' \
        --version='rolling' \
        --no-link \
        "$@"
}

koopa:::install_rust() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2021-05-05.
    # """
    local cargo_prefix file prefix rustup_prefix url version
    # > koopa::assert_is_not_installed rustup-init
    prefix="${INSTALL_PREFIX:?}"
    version="${INSTALL_VERSION:?}"
    rustup_prefix="$prefix"
    cargo_prefix="$(koopa::rust_packages_prefix)"
    koopa::mkdir "$cargo_prefix" "$rustup_prefix"
    CARGO_HOME="$cargo_prefix"
    RUSTUP_HOME="$rustup_prefix"
    export CARGO_HOME RUSTUP_HOME
    koopa::dl \
        'CARGO_HOME' "$CARGO_HOME" \
        'RUSTUP_HOME' "$RUSTUP_HOME"
    url='https://sh.rustup.rs'
    file='rustup.sh'
    koopa::download "$url" "$file"
    chmod +x "$file"
    # Can check the version of install script with '--version'.
    "./${file}" --no-modify-path -v -y
    return 0
}

koopa::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2021-05-11.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local args default jobs name_fancy pkg pkgs pkg_args pos prefix \
        reinstall version
    name_fancy='Rust packages (cargo crates)'
    default=0
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --force|--reinstall)
                reinstall=1
                shift 1
                ;;
            '')
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
    koopa::assert_has_no_envs
    koopa::activate_rust
    if ! koopa::is_installed cargo rustc rustup
    then
        koopa::alert_note 'Required: cargo, rustc, rustup.'
        return 0
    fi
    prefix="${CARGO_HOME:?}"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        default=1
        if koopa::is_installed brew
        then
            koopa::alert_note 'Use Homebrew to manage Rust binaries instead.'
            return 0
        fi
        pkgs=(
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'procs'
            'ripgrep'
            'ripgrep-all'
            'tokei'
            'xsv'
            'zoxide'
        )
    fi
    koopa::install_start "$name_fancy" "$prefix"
    koopa::dl 'Packages' "$(koopa::to_string "${pkgs[@]}")"
    koopa::sys_set_permissions -ru "$prefix"
    jobs="$(koopa::cpu_count)"
    pkg_args=(
        '--jobs' "${jobs}"
        '--verbose'
    )
    [[ "$reinstall" -eq 1 ]] && pkg_flags+=('--force')
    for pkg in "${pkgs[@]}"
    do
        args=("${pkg_args[@]}")
        if [[ "$default" -eq 1 ]]
        then
            version="$(koopa::variable "rust-${pkg}")"
            args+=('--version' "${version}")
        fi
        # Edge case handling for package name variants on crates.io.
        case "$pkg" in
            ripgrep-all)
                pkg='ripgrep_all'
                ;;
        esac
        cargo install "$pkg" "${args[@]}"
    done
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}

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
        koopa::alert_note "${name_fancy} is up-to-date."
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
