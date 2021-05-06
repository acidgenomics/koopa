#!/usr/bin/env bash

# FIXME RENAME THE TARGET TO RUST INSTEAD OF RUSTUP?
# FIXME This should call to koopa::install_app as rustup first.
# FIXME Split out rustup install into a separate script, then call first?
# FIXME This should pick up and use rustup variable correct? Set to rolling.
# FIXME Rename the 'flags' variable.

koopa::install_rust() { # {{{1
    koopa::install_app \
        --name='rust' \
        --name-fancy='Rust' \
        "$@"
}

koopa:::install_rust() { # {{{1
    # """
    # Install Rust (via rustup).
    # @note Updated 2021-05-05.
    # """
    local cargo_prefix file name_fancy pos prefix reinstall rustup_prefix \
        tmp_dir url version
    name_fancy='Rust'
    version='rolling'
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
    koopa::assert_has_no_args "$#"
    cargo_prefix="$(koopa::rust_packages_prefix)"
    rustup_prefix="$(koopa::app_prefix)/rustup/rolling"
    [[ "$reinstall" -eq 1 ]] && koopa::sys_rm "$cargo_prefix" "$rustup_prefix"
    if [[ -d "$cargo_prefix" ]] || [[ -d "$rustup_prefix" ]]
    then
        koopa::alert_note "${name_fancy} is already installed \
at '${rustup_prefix}' and/or '${cargo_prefix}'."
        return 0
    fi
    koopa::assert_is_not_installed rustup-init
    koopa::install_start "$name_fancy"
    koopa::mkdir "$cargo_prefix" "$rustup_prefix"
    CARGO_HOME="$cargo_prefix"
    RUSTUP_HOME="$rustup_prefix"
    export CARGO_HOME RUSTUP_HOME
    koopa::dl \
        'CARGO_HOME' "$CARGO_HOME" \
        'RUSTUP_HOME' "$RUSTUP_HOME"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        url='https://sh.rustup.rs'
        file='rustup.sh'
        koopa::download "$url" "$file"
        chmod +x "$file"
        # Can check the version of install script with '--version'.
        "./${file}" --no-modify-path -v -y
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$cargo_prefix" "$rustup_prefix"
    koopa::link_into_opt "$rustup_prefix" 'rustup'
    koopa::install_success "$name_fancy"
    koopa::alert_restart
    return 0
}

koopa::install_rust_packages() { # {{{1
    # """
    # Install Rust packages.
    # @note Updated 2021-01-22.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local default flags jobs name_fancy pkg pkgs pkg_flags pos prefix \
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
    pkg_flags=(
        '--jobs' "${jobs}"
        '--verbose'
    )
    [[ "$reinstall" -eq 1 ]] && pkg_flags+=('--force')
    for pkg in "${pkgs[@]}"
    do
        flags=("${pkg_flags[@]}")
        if [[ "$default" -eq 1 ]]
        then
            version="$(koopa::variable "rust-${pkg}")"
            flags+=('--version' "${version}")
        fi
        cargo install "$pkg" "${flags[@]}"
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
