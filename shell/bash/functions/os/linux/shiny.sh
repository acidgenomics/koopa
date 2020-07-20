#!/usr/bin/env bash

koopa::shiny_server_restart() { # {{{1
    koopa::assert_has_no_args "$#"
    sudo systemctl restart shiny-server
    return 0
}

koopa::shiny_server_start() { # {{{1
    koopa::assert_has_no_args "$#"
    sudo systemctl start shiny-server
    return 0
}

koopa::shiny_server_status() { # {{{1
    koopa::assert_has_no_args "$#"
    sudo systemctl status shiny-server
    return 0
}
