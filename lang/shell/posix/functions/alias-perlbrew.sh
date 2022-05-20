#!/bin/sh

koopa_alias_perlbrew() {
    # """
    # Perlbrew alias.
    # @note Updated 2021-05-26.
    # """
    koopa_is_alias 'perlbrew' && unalias 'perlbrew'
    koopa_activate_perlbrew
    perlbrew "$@"
}
