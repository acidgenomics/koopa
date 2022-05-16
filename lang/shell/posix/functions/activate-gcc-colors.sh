#!/bin/sh

koopa_activate_gcc_colors() {
    # """
    # Activate GCC colors.
    # @note Updated 2020-06-30.
    # @seealso
    # - https://gcc.gnu.org/onlinedocs/gcc-10.1.0/gcc/
    #     Diagnostic-Message-Formatting-Options.html
    # """
    [ -n "${GCC_COLORS:-}" ] && return 0
    export GCC_COLORS="caret=01;32:error=01;31:locus=01:note=01;36:\
quote=01:warning=01;35"
    return 0
}
