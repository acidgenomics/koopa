#!/usr/bin/env bash

koopa::install_rust() { # {{{1
    # """
    # Install Rust.
    # @note Updated 2020-12-02.
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
    koopa::link_into_opt "$prefix" "$name"
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
        koopa::cd "$tmp_dir"
        url='https://sh.rustup.rs'
        file='rustup.sh'
        koopa::download "$url" "$file"
        chmod +x "$file"
        "./${file}" --no-modify-path -v -y
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::sys_set_permissions -r "$CARGO_HOME" "$RUSTUP_HOME"
    koopa::install_success "$name_fancy"
    # Clippy and rustfmt should be enabled by default.
    # > rustup component add clippy-preview
    # > rustup component add rustfmt
    koopa::restart
    return 0
}
