#!/usr/bin/env bash

koopa_cli_install() {
    # """
    # Parse user input to 'koopa install'.
    # @note Updated 2022-07-14.
    #
    # @examples
    # > koopa_cli_install --binary --reinstall --verbose 'python' 'tmux'
    # > koopa_cli_install user 'doom-emacs' 'spacemacs'
    # """
    local app dict flags pos stem
    koopa_assert_has_args "$#"
    declare -A dict=(
        [allow_custom]=0
        [custom_enabled]=0
        [stem]='install'
    )
    case "${1:-}" in
        'koopa')
            dict[allow_custom]=1
            ;;
        '--all')
            koopa_install_all_apps
            return 0
            ;;
    esac
    flags=()
    pos=()
    while (("$#"))
    do
        case "$1" in
            '--binary' | \
            '--push' | \
            '--reinstall' | \
            '--verbose')
                flags+=("$1")
                shift 1
                ;;
            '-'*)
                if [[ "${dict[allow_custom]}" -eq 1 ]]
                then
                    dict[custom_enabled]=1
                    pos+=("$1")
                    shift 1
                else
                    koopa_invalid_arg "$1"
                fi
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "${1:-}" in
        'system' | \
        'user')
            dict[stem]="${dict[stem]}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    if [[ "${dict[custom_enabled]}" -eq 1 ]]
    then
        dict[key]="${dict[stem]}-${1:?}"
        shift 1
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop 'Unsupported app.'
        fi
        "${dict[fun]}" "$@"
        return 0
    fi
    for app in "$@"
    do
        local dict2
        declare -A dict2=(
            [key]="${dict[stem]}-${app}"
        )
        dict2[fun]="$(koopa_which_function "${dict2[key]}" || true)"
        if ! koopa_is_function "${dict2[fun]}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict2[fun]}" "${flags[@]}"
    done
    return 0
}
