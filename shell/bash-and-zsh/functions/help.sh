#!/usr/bin/env bash

_koopa_help() { # {{{1
    # """
    # Show usage via '--help' flag.
    # @note Updated 2020-07-01.
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
    #   This approach is supported in zsh 5.7.1, but will error in older zsh
    #   versions, such as on Travis CI. This is the same as the value of $0 when
    #   the POSIX_ARGZERO option is set, but is always available. 
    #   > file="${ZSH_ARGZERO:?}"
    #
    # See also:
    # - https://stackoverflow.com/questions/192319
    # - http://zsh.sourceforge.net/Doc/Release/Parameters.html
    # - https://stackoverflow.com/questions/35677745
    # """
    [[ "$#" -eq 0 ]] && return 0
    [[ "${1:-}" == "" ]] && return 0
    local arg args first_arg last_arg man_file prefix script_name
    first_arg="${1:?}"
    last_arg="${!#}"
    args=("$first_arg" "$last_arg")
    for arg in "${args[@]}"
    do
        case "$arg" in
            --help|-h)
                _koopa_assert_is_installed man
                local file
                case "$(_koopa_shell)" in
                    bash)
                        file="$0"
                        ;;
                    zsh)
                        emulate sh -o POSIX_ARGZERO
                        file="$0"
                        ;;
                    *)
                        _koopa_stop "Unsupported shell."
                        ;;
                esac
                file="$(realpath "$file")"
                script_name="$(basename "$file")"
                prefix="$(dirname "$(dirname "$file")")"
                man_file="${prefix}/man/man1/${script_name}.1"
                if [[ -s "$man_file" ]]
                then
                    head -n 1 "$man_file" \
                        | _koopa_str_match_regex "^\.TH " \
                        || _koopa_stop "Invalid documentation at '${man_file}'."
                else
                    _koopa_stop "No documentation for '${script_name}'."
                fi
                man "$man_file"
                exit 0
                ;;
        esac
    done
    return 0
}
