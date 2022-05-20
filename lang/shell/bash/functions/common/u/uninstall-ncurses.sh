#!/usr/bin/env bash

koopa_uninstall_ncurses() {
    koopa_uninstall_app \
        --name='ncurses' \
        --unlink-in-bin='captoinfo' \
        --unlink-in-bin='clear' \
        --unlink-in-bin='infocmp' \
        --unlink-in-bin='infotocap' \
        --unlink-in-bin='reset' \
        --unlink-in-bin='tabs' \
        --unlink-in-bin='tic' \
        --unlink-in-bin='toe' \
        --unlink-in-bin='tput' \
        --unlink-in-bin='tset' \
        "$@"
}
