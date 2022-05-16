#!/bin/sh

koopa_expr() {
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # @note Updated 2020-06-30.
    # """
    expr "${1:?}" : "${2:?}" 1>/dev/null
}
