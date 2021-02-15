#!/usr/bin/env bash

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
        koopa::note 'Required: cargo, rustc, rustup.'
        return 0
    fi
    prefix="${CARGO_HOME:?}"
    pkgs=("$@")
    if [[ "${#pkgs[@]}" -eq 0 ]]
    then
        default=1
        if koopa::is_installed brew
        then
            koopa::note 'Use Homebrew to manage Rust binaries.'
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
