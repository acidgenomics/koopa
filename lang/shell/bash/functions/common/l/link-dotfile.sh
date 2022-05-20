#!/usr/bin/env bash

koopa_link_dotfile() {
    # """
    # Link dotfile.
    # @note Updated 2022-04-04.
    # """
    local dict pos
    koopa_assert_has_args "$#"
    declare -A dict=(
        [dotfiles_config_link]="$(koopa_dotfiles_config_link)"
        [dotfiles_prefix]="$(koopa_dotfiles_prefix)"
        [dotfiles_private_prefix]="$(koopa_dotfiles_private_prefix)"
        [from_opt]=0
        [into_xdg_config_home]=0
        [opt_prefix]="$(koopa_opt_prefix)"
        [overwrite]=0
        [private]=0
        [xdg_config_home]="$(koopa_xdg_config_home)"
    )
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--from-opt')
                dict[from_opt]=1
                shift 1
                ;;
            '--into-xdg-config-home')
                dict[into_xdg_config_home]=1
                shift 1
                ;;
            '--overwrite')
                dict[overwrite]=1
                shift 1
                ;;
            '--private')
                dict[private]=1
                shift 1
                ;;
            '-'*)
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa_assert_has_args_le "$#" 2
    dict[source_subdir]="${1:?}"
    dict[symlink_basename]="${2:-}"
    if [[ -z "${dict[symlink_basename]}" ]]
    then
        dict[symlink_basename]="$(koopa_basename "${dict[source_subdir]}")"
    fi
    if [[ "${dict[from_opt]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[opt_prefix]}"
    elif [[ "${dict[private]}" -eq 1 ]]
    then
        dict[source_prefix]="${dict[dotfiles_private_prefix]}"
    else
        dict[source_prefix]="${dict[dotfiles_config_link]}"
        if [[ ! -L "${dict[source_prefix]}" ]]
        then
            koopa_ln "${dict[dotfiles_prefix]}" "${dict[source_prefix]}"
        fi
    fi
    dict[source_path]="${dict[source_prefix]}/${dict[source_subdir]}"
    if [[ "${dict[from_opt]}" -eq 1 ]] && [[ ! -e "${dict[source_path]}" ]]
    then
        koopa_warn "Does not exist: '${dict[source_path]}'."
        return 0
    fi
    koopa_assert_is_existing "${dict[source_path]}"
    if [[ "${dict[into_xdg_config_home]}" -eq 1 ]]
    then
        dict[symlink_prefix]="${dict[xdg_config_home]}"
    else
        dict[symlink_prefix]="${HOME:?}"
        dict[symlink_basename]=".${dict[symlink_basename]}"
    fi
    dict[symlink_path]="${dict[symlink_prefix]}/${dict[symlink_basename]}"
    if [[ "${dict[overwrite]}" -eq 1 ]] ||
        { [[ -L "${dict[symlink_path]}" ]] && \
            [[ ! -e "${dict[symlink_path]}" ]]; }
    then
        koopa_rm "${dict[symlink_path]}"
    fi
    if [[ -e "${dict[symlink_path]}" ]] && \
        [[ ! -L "${dict[symlink_path]}" ]]
    then
        koopa_alert_note "Exists and not symlink: '${dict[symlink_path]}'."
        return 0
    fi
    koopa_alert "Linking dotfile from '${dict[source_path]}' \
to '${dict[symlink_path]}'."
    dict[symlink_dirname]="$(koopa_dirname "${dict[symlink_path]}")"
    if [[ "${dict[symlink_dirname]}" != "${HOME:?}" ]]
    then
        koopa_mkdir "${dict[symlink_dirname]}"
    fi
    koopa_ln "${dict[source_path]}" "${dict[symlink_path]}"
    return 0
}
