#!/usr/bin/env bash

koopa::list_internal_functions() { # {{{1
    # """
    # List all functions defined by koopa.
    # @note Updated 2020-06-30.
    #
    # Currently only supported in Bash and Zsh.
    # """
    koopa::assert_has_no_args "$#"
    local x
    case "$(koopa::shell)" in
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
            koopa::warning 'Unsupported shell.'
            return 1
            ;;
    esac
    x="$(koopa::print "$x" | grep -E "^koopa::")"
    koopa::print "$x"
    return 0
}

koopa::unset_internal_functions() { # {{{1
    # """
    # Unset all of koopa's internal functions.
    # @note Updated 2020-06-30.
    #
    # Currently only supported in Bash and Zsh.
    #
    # Potentially useful as a final clean-up step for activation.
    # Note that this will nuke functions currently required for interactive
    # prompt, so don't do this yet.
    # """
    koopa::assert_has_no_args "$#"
    local funs
    case "$(koopa::shell)" in
        bash)
            # shellcheck disable=SC2119
            readarray -t funs <<< "$(koopa::list_internal_functions)"
            ;;
        zsh)
            # shellcheck disable=SC2119
            funs=("${(@f)$(koopa::list_internal_functions)}")
            ;;
        *)
            koopa::warning 'Unsupported shell.'
            return 1
            ;;
    esac
    unset -f "${funs[@]}"
    return 0
}
