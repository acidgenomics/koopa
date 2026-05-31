#!/bin/sh

_koopa_add_to_manpath_end() {
    # """
    # Force add to 'MANPATH' end.
    # @note Updated 2023-03-10.
    # """
    MANPATH="${MANPATH:-}"
    for __kvar_dir in "$@"
    do
        [ -d "$__kvar_dir" ] || continue
        case ":${MANPATH}:" in
            *":${__kvar_dir}:"*)
                __kvar_new=''
                __kvar_ifs="$IFS"
                IFS=':'
                # shellcheck disable=SC2086
                set -- ${MANPATH}
                IFS="$__kvar_ifs"
                for __kvar_d in "$@"
                do
                    [ "$__kvar_d" = "$__kvar_dir" ] && continue
                    __kvar_new="${__kvar_new:+${__kvar_new}:}${__kvar_d}"
                done
                MANPATH="${__kvar_new}:${__kvar_dir}"
                unset -v __kvar_d __kvar_ifs __kvar_new
                ;;
            *)
                MANPATH="${MANPATH}:${__kvar_dir}"
                ;;
        esac
    done
    export MANPATH
    unset -v __kvar_dir
    return 0
}
