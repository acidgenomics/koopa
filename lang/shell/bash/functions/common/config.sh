#!/usr/bin/env bash

koopa::add_make_prefix_link() { # {{{1
    # """
    # Ensure 'koopa' is linked inside make prefix.
    # @note Updated 2020-07-20.
    #
    # This is particularly useful for external scripts that source koopa header.
    # This approach works nicely inside a hardened R environment.
    # """
    local koopa_prefix make_prefix source_link target_link
    koopa::assert_has_args_le "$#" 1
    koopa::is_shared_install || return 0
    koopa_prefix="${1:-}"
    [[ -z "$koopa_prefix" ]] && koopa_prefix="$(koopa::prefix)"
    make_prefix="$(koopa::make_prefix)"
    [[ -d "$make_prefix" ]] || return 0
    target_link="${make_prefix}/bin/koopa"
    [[ -L "$target_link" ]] && return 0
    koopa::alert "Adding 'koopa' link inside '${make_prefix}'."
    source_link="${koopa_prefix}/bin/koopa"
    koopa::sys_ln "$source_link" "$target_link"
    return 0
}

koopa::add_monorepo_config_link() { # {{{1
    # """
    # Add koopa configuration link from user's git monorepo.
    # @note Updated 2021-05-24.
    # """
    local monorepo_prefix subdir
    koopa::assert_has_args "$#"
    koopa::assert_has_monorepo
    monorepo_prefix="$(koopa::monorepo_prefix)"
    for subdir in "$@"
    do
        koopa::add_config_link \
            "${monorepo_prefix}/${subdir}" \
            "$subdir"
    done
    return 0
}

koopa::add_to_user_profile() { # {{{1
    # """
    # Add koopa configuration to user profile.
    # @note Updated 2021-04-09.
    # """
    local source_file target_file
    koopa::assert_has_no_args "$#"
    target_file="$(koopa::find_user_profile)"
    source_file="$(koopa::prefix)/lang/shell/posix/include/profile.sh"
    koopa::assert_is_file "$source_file"
    koopa::alert "Adding koopa activation to '${target_file}'."
    touch "$target_file"
    cat "$source_file" >> "$target_file"
    return 0
}

koopa::delete_dotfile() { # {{{1
    # """
    # Delete a dot file.
    # @note Updated 2020-07-20.
    # """
    local filepath name
    koopa::assert_has_args "$#"
    for name in "$@"
    do
        name="${1:?}"
        filepath="${HOME:?}/.${name}"
        if [[ -L "$filepath" ]]
        then
            koopa::alert "Removing '${filepath}'."
            koopa::rm "$filepath"
        elif [[ -f "$filepath" ]] || [[ -d "$filepath" ]]
        then
            koopa::warning "Not a symlink: '${filepath}'."
        fi
    done
    return 0
}

koopa::find_user_profile() { # {{{1
    # """
    # Find current user's shell profile configuration file.
    # @note Updated 2021-05-15.
    # """
    local file shell
    koopa::assert_has_no_args "$#"
    shell="$(koopa::shell_name)"
    case "$shell" in
        bash)
            file="${HOME}/.bashrc"
            ;;
        zsh)
            file="${HOME}/.zshrc"
            ;;
        *)
            file="${HOME}/.profile"
            ;;
    esac
    [[ -n "$file" ]] || return 1
    koopa::print "$file"
    return 0
}

koopa::fix_pyenv_permissions() { # {{{1
    # """
    # Ensure Python pyenv shims have correct permissions.
    # @note Updated 2020-07-30.
    # """
    local pyenv_prefix
    koopa::assert_has_no_args "$#"
    pyenv_prefix="$(koopa::pyenv_prefix)"
    [[ -d "${pyenv_prefix}/shims" ]] || return 0
    koopa::sys_chmod 0777 "${pyenv_prefix}/shims"
    return 0
}

koopa::fix_rbenv_permissions() { # {{{1
    # """
    # Ensure Ruby rbenv shims have correct permissions.
    # @note Updated 2020-07-30.
    # """
    local rbenv_prefix
    koopa::assert_has_no_args "$#"
    rbenv_prefix="$(koopa::rbenv_prefix)"
    [[ -d "${rbenv_prefix}/shims" ]] || return 0
    koopa::sys_chmod 0777 "${rbenv_prefix}/shims"
    return 0
}

koopa::fix_zsh_permissions() { # {{{1
    # """
    # Fix ZSH permissions, to ensure compaudit checks pass.
    # @note Updated 2021-03-18.
    # """
    local app_prefix koopa_prefix make_prefix
    koopa::assert_has_no_args "$#"
    koopa::alert 'Fixing Zsh permissions.'
    koopa_prefix="$(koopa::prefix)"
    koopa::sys_chmod 'g-w' \
        "${koopa_prefix}/lang/shell/zsh" \
        "${koopa_prefix}/lang/shell/zsh/functions"
    koopa::is_installed 'zsh' || return 0
    make_prefix="$(koopa::make_prefix)"
    if [[ -d "${make_prefix}/share/zsh/site-functions" ]]
    then
        if koopa::str_match_regex \
            "$(koopa::which zsh)" "^${make_prefix}"
        then
            koopa::sys_chmod 'g-w' \
                "${make_prefix}/share/zsh" \
                "${make_prefix}/share/zsh/site-functions"
        fi
    fi
    app_prefix="$(koopa::app_prefix)"
    if [[ -d "$app_prefix" ]]
    then
        if koopa::str_match_regex \
            "$(koopa::which_realpath zsh)" "^${app_prefix}"
        then
            koopa::sys_chmod 'g-w' \
                "${app_prefix}/zsh/"*'/share/zsh' \
                "${app_prefix}/zsh/"*'/share/zsh/'* \
                "${app_prefix}/zsh/"*'/share/zsh/'*'/functions'
        fi
    fi
    koopa::alert_success 'Zsh permissions should pass compaudit checks.'
    return 0
}

koopa::git_clone_dotfiles() { # {{{1
    # """
    # Clone dotfiles repo.
    # @note Updated 2020-07-04.
    # """
    koopa::assert_has_no_args "$#"
    koopa::git_clone \
        'https://github.com/acidgenomics/dotfiles.git' \
        "$(koopa::dotfiles_prefix)"
    return 0
}

koopa::info_box() { # {{{1
    # """
    # Configuration information box.
    # @note Updated 2021-03-30.
    #
    # Using unicode box drawings here.
    # Note that we're truncating lines inside the box to 68 characters.
    # """
    koopa::assert_has_args "$#"
    local array
    array=("$@")
    local barpad
    barpad="$(printf '━%.0s' {1..70})"
    printf '  %s%s%s  \n' '┏' "$barpad" '┓'
    for i in "${array[@]}"
    do
        printf '  ┃ %-68s ┃  \n' "${i::68}"
    done
    printf '  %s%s%s  \n\n' '┗' "$barpad" '┛'
    return 0
}

koopa::ip_address() { # {{{1
    # """
    # IP address.
    # @note Updated 2020-07-14.
    # """
    type='public'
    while (("$#"))
    do
        case "$1" in
            --local)
                type='local'
                shift 1
                ;;
            --public)
                type='public'
                shift 1
                ;;
            *)
                koopa::invalid_arg "$1"
                ;;
        esac
    done
    case "$type" in
        local)
            koopa::local_ip_address
            ;;
        public)
            koopa::public_ip_address
            ;;
    esac
    return 0
}

koopa::link_dotfile() { # {{{1
    # """
    # Link dotfile.
    # @note Updated 2021-05-26.
    # """
    local config dot_dir dot_repo force pos private source_name
    local symlink_name xdg_config_home
    koopa::assert_has_args "$#"
    config=0
    force=0
    private=0
    pos=()
    while (("$#"))
    do
        case "$1" in
            --config)
                config=1
                shift 1
                ;;
            --force)
                force=1
                shift 1
                ;;
            --private)
                private=1
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
    koopa::assert_has_args_le "$#" 2
    source_name="$1"
    symlink_name="${2:-}"
    if [[ "$private" -eq 1 ]]
    then
        dot_dir="$(koopa::dotfiles_private_config_link)"
    else
        # e.g. ~/.config/koopa/dotfiles
        dot_dir="$(koopa::dotfiles_config_link)"
        # Note that this step automatically links into koopa config for users.
        if [[ ! -d "$dot_dir" ]]
        then
            dot_repo="$(koopa::dotfiles_prefix)"
            koopa::rm "$dot_dir"
            koopa::ln "$dot_repo" "$dot_dir"
        fi
    fi
    koopa::assert_is_dir "$dot_dir"
    source_path="${dot_dir}/${source_name}"
    koopa::assert_is_existing "$source_path"
    # Define optional target symlink name.
    if [[ -z "$symlink_name" ]]
    then
        symlink_name="$(basename "$source_path")"
    fi
    if [[ "$config" -eq 1 ]]
    then
        xdg_config_home="$(koopa::xdg_config_home)"
        [[ -z "$xdg_config_home" ]] && xdg_config_home="${HOME:?}/.config"
        symlink_path="${xdg_config_home}/${symlink_name}"
    else
        symlink_path="${HOME:?}/.${symlink_name}"
    fi
    # Inform the user when nuking a broken symlink.
    if [[ "$force" -eq 1 ]] ||
        { [[ -L "$symlink_path" ]] && [[ ! -e "$symlink_path" ]]; }
    then
        koopa::rm "$symlink_path"
    elif [[ -e "$symlink_path" ]]
    then
        koopa::stop "Existing dotfile: '${symlink_path}'."
        return 1
    fi
    koopa::dl "$symlink_path" "$source_path"
    symlink_dn="$(dirname "$symlink_path")"
    [[ "$symlink_dn" != "${HOME:?}" ]] && koopa::mkdir "$symlink_dn"
    koopa::ln "$source_path" "$symlink_path"
    return 0
}
