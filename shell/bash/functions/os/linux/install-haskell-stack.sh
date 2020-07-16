#!/usr/bin/env bash

koopa::install_haskell_stack() {
    local file name_fancy tmp_dir url xdg_bin_dir
    koopa::assert_has_no_args "$#"
    koopa::assert_has_no_envs
    name_fancy="Haskell stack"
    koopa::install_start "$name_fancy"
    # Installer will warn if this local directory doesn't exist.
    xdg_bin_dir="${HOME}/.local/bin"
    koopa::mkdir "$xdg_bin_dir"
    koopa::add_to_path_start "$xdg_bin_dir"
    tmp_dir="$(koopa::tmp_dir)"
    (
        koopa::cd "$tmp_dir"
        url='https://get.haskellstack.org/'
        file='stack.sh'
        koopa::download "$url" "$file"
        chmod +x "$file"
        "$file"
    ) 2>&1 | tee "$(koopa::tmp_log_file)"
    koopa::rm "$tmp_dir"
    koopa::install_success "$name_fancy"
    return 0
}

