#!/bin/sh

_koopa_deactivate_inherited_direnv() {
    # """
    # Revert direnv exports inherited from a parent process.
    # @note Updated 2026-09-05.
    #
    # '_koopa_activate_direnv' unsets 'DIRENV_DIFF' (direnv's own record of
    # what it previously exported) on every shell start, without first
    # reverting the exports that diff describes. A long-lived parent process
    # (e.g. an editor launched with 'code .' from inside a project) captures
    # those exports at launch, and every child shell then inherits them with
    # no way to undo them, in any directory, for the life of the process
    # tree. This includes any secret exported by the parent's '.envrc' via
    # 'dotenv_if_exists'.
    #
    # Revert here, from a neutral directory ('/', which never has its own
    # '.envrc'), using direnv's own diff, before
    # '_koopa_activate_path_helper' runs. The revert emits an 'export PATH='
    # that restores the parent shell's 'PATH'; running this after the 'PATH'
    # build would clobber it with a stale value.
    #
    # @seealso
    # - https://direnv.net/docs/hook.html
    # """
    if [ -z "${DIRENV_DIFF:-}" ]
    then
        return 0
    fi
    __kvar_direnv="${KOOPA_PREFIX:?}/bin/direnv"
    if [ ! -x "$__kvar_direnv" ]
    then
        unset -v __kvar_direnv
        return 0
    fi
    __kvar_shell="${KOOPA_SHELL##*/}"
    case "$__kvar_shell" in
        'bash' | 'zsh')
            eval "$(cd / && "$__kvar_direnv" export "$__kvar_shell" 2>/dev/null)"
            ;;
    esac
    unset -v __kvar_direnv __kvar_shell
    return 0
}
