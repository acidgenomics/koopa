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
    local app flags pos stem
    koopa_assert_has_args "$#"
    case "${1:-}" in
        '--all')
            koopa_install_all_apps
            return 0
            ;;
    esac
    flags=()
    pos=()
    stem='install'
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
                koopa_invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    case "$1" in
        'system' | \
        'user')
            stem="${stem}-${1}"
            shift 1
            ;;
    esac
    koopa_assert_has_args "$#"
    for app in "$@"
    do
        local dict
        declare -A dict=(
            [key]="${stem}-${app}"
        )
        dict[fun]="$(koopa_which_function "${dict[key]}" || true)"
        if ! koopa_is_function "${dict[fun]}"
        then
            koopa_stop "Unsupported app: '${app}'."
        fi
        "${dict[fun]}" "${flags[@]}"
    done
    return 0
}
