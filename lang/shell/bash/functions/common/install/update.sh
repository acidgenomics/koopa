#!/usr/bin/env bash

koopa::update_chemacs() { # {{{1
    koopa::update_app \
        --name='chemacs' \
        --name-fancy='Chemacs' \
        "$@"
}

koopa::update_julia_packages() { # {{{1
    koopa::install_julia_packages "$@"
}

koopa::update_koopa() { # {{{1
    koopa::update_app \
        --name='koopa' \
        --prefix="$(koopa::koopa_prefix)" \
        --system \
        "$@"
}

koopa::update_nim_packages() { # {{{1
    koopa::install_nim_packages "$@"
}

koopa::update_node_packages() { # {{{1
    koopa::install_node_packages "$@"
}

koopa::update_perl_packages() { # {{{1
    koopa::install_perl_packages "$@"
}

koopa::update_tex_packages() { # {{{1
    koopa::update_app \
        --name-fancy='TeX packages' \
        --name='tex-packages' \
        --system \
        "$@"
}
