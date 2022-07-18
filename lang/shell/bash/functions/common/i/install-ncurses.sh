#!/usr/bin/env bash

koopa_install_ncurses() {
    koopa_install_app \
        --link-in-bin='captoinfo' \
        --link-in-bin='clear' \
        --link-in-bin='infocmp' \
        --link-in-bin='infotocap' \
        --link-in-bin='reset' \
        --link-in-bin='tabs' \
        --link-in-bin='tic' \
        --link-in-bin='toe' \
        --link-in-bin='tput' \
        --link-in-bin='tset' \
        --name='ncurses' \
        "$@"
}
