#!/usr/bin/env bash

koopa::install_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2020-11-24.
    # """
    local file name name_fancy pos prefix reinstall tmp_dir url
    name='rust'
    name_fancy='Rust'
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
    prefix="$(koopa::app_prefix)/${name}/rolling"
    [[ "$reinstall" -eq 1 ]] && koopa::sys_rm "$prefix"
    if [[ -d "$prefix" ]]
    then
        koopa::note "${name_fancy} is already installed at '${prefix}'."
        return 0
    fi
    koopa::link_opt "$prefix" "$name"
    CARGO_HOME="$(koopa::rust_cargo_prefix)"
    RUSTUP_HOME="$(koopa::rust_rustup_prefix)"
    export CARGO_HOME
    export RUSTUP_HOME
    if [[ -d "$CARGO_HOME" ]] && [[ -d "$RUSTUP_HOME" ]]
    then
        koopa::note "${name_fancy} is already installed at '${CARGO_HOME}'."
        return 0
    fi
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
    # @note Updated 2020-11-17.
    #
    # Cargo documentation:
    # https://doc.rust-lang.org/cargo/
    #
    # install-update now supported:
    # - https://stackoverflow.com/questions/34484361
    # - https://github.com/rust-lang/cargo/pull/6798
    # - https://github.com/rust-lang/cargo/pull/7560
    # """
    local cargo_flags crate crates default flags jobs name_fancy pos prefix \
        reinstall version
    default=0
    reinstall=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --reinstall)
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
    name_fancy='Rust cargo crates'
    prefix="${CARGO_HOME:?}"
    koopa::install_start "$name_fancy" "$prefix"
    crates=("$@")
    if [[ "${#crates[@]}" -eq 0 ]]
    then
        default=1
        crates=(
            'bat'
            'broot'
            'du-dust'
            'exa'
            'fd-find'
            'hyperfine'
            'procs'
            'ripgrep'
            'tokei'
            'xsv'
            'zoxide'
        )
    fi
    koopa::dl 'Crates' "$(koopa::to_string "${crates[@]}")"
    koopa::sys_set_permissions -ru "$prefix"
    jobs="$(koopa::cpu_count)"
    cargo_flags=(
        '--jobs' "${jobs}"
        '--verbose'
    )
    [[ "$reinstall" -eq 1 ]] && cargo_flags+=('--force')
    for crate in "${crates[@]}"
    do
        flags=("${cargo_flags[@]}")
        if [[ "$default" -eq 1 ]]
        then
            version="$(koopa::variable "rust-${crate}")"
            flags+=('--version' "${version}")
        fi
        cargo install "$crate" "${flags[@]}"
    done
    koopa::sys_set_permissions -r "$prefix"
    koopa::install_success "$name_fancy"
    return 0
}
