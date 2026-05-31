#!/bin/sh

_koopa_add_to_manpath_start() {
    # """
    # Force add to 'MANPATH' start.
    # @note Updated 2022-03-10.
    #
    # @seealso
    # - /etc/manpath.config
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
                MANPATH="${__kvar_dir}:${__kvar_new}"
                unset -v __kvar_d __kvar_ifs __kvar_new
                ;;
            *)
                MANPATH="${__kvar_dir}:${MANPATH}"
                ;;
        esac
    done
    export MANPATH
    unset -v __kvar_dir
    return 0
}
