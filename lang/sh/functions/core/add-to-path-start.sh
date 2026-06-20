#!/bin/sh

_koopa_add_to_path_start() {
    # """
    # Force add to 'PATH' start.
    # @note Updated 2023-03-10.
    # """
    PATH="${PATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        case ":${PATH}:" in
            *":${__kvar_dir}:"*)
                __kvar_new=''
                __kvar_ifs="$IFS"
                IFS=':'
                # shellcheck disable=SC2086
                set -- ${PATH}
                IFS="$__kvar_ifs"
                for __kvar_d in "$@"
                do
                    [ "$__kvar_d" = "$__kvar_dir" ] && continue
                    __kvar_new="${__kvar_new:+${__kvar_new}:}${__kvar_d}"
                done
                PATH="${__kvar_dir}:${__kvar_new}"
                unset -v __kvar_d __kvar_ifs __kvar_new
                ;;
            *)
                PATH="${__kvar_dir}:${PATH}"
                ;;
        esac
    done
    export PATH
    unset -v __kvar_dir
    return 0
}
