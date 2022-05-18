#!/usr/bin/env bash

koopa_install_ncurses() {
    koopa_install_app \
        --link-in-bin='bin/captoinfo' \
        --link-in-bin='bin/clear' \
        --link-in-bin='bin/infocmp' \
        --link-in-bin='bin/infotocap' \
        --link-in-bin='bin/reset' \
        --link-in-bin='bin/tabs' \
        --link-in-bin='bin/tic' \
        --link-in-bin='bin/toe' \
        --link-in-bin='bin/tput' \
        --link-in-bin='bin/tset' \
        --name='ncurses' \
        "$@"
}
