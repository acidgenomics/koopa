#!/usr/bin/env bash

koopa_is_x86_64() {
    # """
    # Is the architecture Intel x86 64-bit?
    # @note Updated 2023-10-09.
    # """
    case "$(koopa_arch)" in
        'x86_64')
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}
