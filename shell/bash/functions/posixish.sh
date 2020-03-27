#!/usr/bin/env bash

_koopa_help() {  # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2020-01-21.
    #
    # Note that using 'path' as a local variable here will mess up Zsh.
    #
    # Now always calls 'man' to display nicely formatted manual page.
    #
    # Bash alternate approach:
    # > file="${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}"
    #
    # Zsh parameter notes:
    # - '$0': The name used to invoke the current shell, or as set by the -c
    #   command line option upon invocation. If the FUNCTION_ARGZERO option is
    #   set, $0 is set upon entry to a shell function to the name of the
    #   function, and upon entry to a sourced script to the name of the script,
    #   and reset to its previous value when the function or script returns.
    # - 'FUNCTION_ARGZERO': When executing a shell function or sourcing a
    #   script, set $0 temporarily to the name of the function/script. Note that
    #   toggling FUNCTION_ARGZERO from on to off (or off to on) does not change
    #   the current value of $0. Only the state upon entry to the function or
    #   script has an effect. Compare POSIX_ARGZERO.
    # - 'POSIX_ARGZERO': This option may be used to temporarily disable
    #   FUNCTION_ARGZERO and thereby restore the value of $0 to the name used to
    #   invoke the shell (or as set by the -c command line option). For
    #   compatibility with previous versions of the shell, emulations use
    #   NO_FUNCTION_ARGZERO instead of POSIX_ARGZERO, which may result in
    #   unexpected scoping of $0 if the emulation mode is changed inside a
    #   function or script. To avoid this, explicitly enable POSIX_ARGZERO in
    #   the emulate command:
    #
    #   emulate sh -o POSIX_ARGZERO
    #
    #   Note that NO_POSIX_ARGZERO has no effect unless FUNCTION_ARGZERO was
    #   already enabled upon entry to the function or script. 
    #
    # See also:
    # - https://stackoverflow.com/questions/192319
    # - http://zsh.sourceforge.net/Doc/Release/Parameters.html
    # - https://stackoverflow.com/questions/35677745
    # """
    case "${1:-}" in
        --help|-h)
            _koopa_assert_is_installed man
            local file
            case "$(_koopa_shell)" in
                bash)
                    file="$0"
                    ;;
                zsh)
                    # This approach is supported in zsh 5.7.1, but will error
                    # in older zsh versions, such as on Travis CI. This is the
                    # same as the value of $0 when the POSIX_ARGZERO option is
                    # set, but is always available. 
                    # > file="${ZSH_ARGZERO:?}"
                    emulate sh -o POSIX_ARGZERO
                    file="$0"
                    ;;
                *)
                    _koopa_warning "Unsupported shell."
                    exit 1
                    ;;
            esac
            local name
            name="${file##*/}"
            man "$name"
            exit 0
            ;;
    esac
    return 0
}

_koopa_is_set() {  # {{{1
    # """
    # Is the variable set and non-empty?
    # @note Updated 2020-03-27.
    #
    # Note that usage of 'declare' here is a bashism.
    # Can consider using 'type' instead for POSIX compliance.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3601515
    # - https://unix.stackexchange.com/questions/504082
    # - https://www.gnu.org/software/bash/manual/html_node/
    #       Shell-Parameter-Expansion.html
    # """
    local var
    var="${1:?}"

    # Check if variable is defined.
    local x
    x="$(declare -p "$var" 2>/dev/null || true)"
    [ -n "$x" ] || return 1

    # Check if variable contains non-empty value.
    local value
    case "$(_koopa_shell)" in
        bash)
            value="${!var}"
            ;;
        zsh)
            # shellcheck disable=SC2154
            value="${(P)var}"
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 1
            ;;
    esac
    [ -n "$value" ] || return 1

    return 0
}

_koopa_list_internal_functions() {  # {{{1
    # """
    # List all functions defined by koopa.
    # @note Updated 2020-02-19.
    #
    # Currently only supported in Bash and Zsh.
    # """
    local x
    case "$(_koopa_shell)" in
        bash)
            x="$( \
                declare -F \
                | sed "s/^declare -f //g" \
            )"
            ;;
        zsh)
            # shellcheck disable=SC2086,SC2154
            x="$(print -l ${(ok)functions})"
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 1
            ;;
    esac
    x="$(_koopa_print "$x" | grep -E "^_koopa_")"
    _koopa_print "$x"
    return 0
}

_koopa_unset_internal_functions() {  # {{{1
    # """
    # Unset all of koopa's internal functions.
    # @note Updated 2020-03-27.
    #
    # Currently only supported in Bash and Zsh.
    #
    # Potentially useful as a final clean-up step for activation.
    # Note that this will nuke functions currently required for interactive
    # prompt, so don't do this yet.
    # """
    local funs
    case "$(_koopa_shell)" in
        bash)
            # shellcheck disable=SC2119
            mapfile -t funs < <(_koopa_list_internal_functions)
            ;;
        zsh)
            # shellcheck disable=SC2119
            funs=("${(@f)$(_koopa_list_internal_functions)}")
            ;;
        *)
            _koopa_warning 'Unsupported shell.'
            return 1
            ;;
    esac
    unset -f "${funs[@]}"
    return 0
}
