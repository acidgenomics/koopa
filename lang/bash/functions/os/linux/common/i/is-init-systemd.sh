#!/usr/bin/env bash

koopa_linux_is_init_systemd() {
    # """
    # Has the system been booted with systemd as the init system?
    # @note Updated 2023-05-30.
    #
    # Otherwise, can run into this error message (e.g. inside of Docker):
    # System has not been booted with systemd as init system (PID 1). Can't
    # operate. Failed to create bus connection: Host is down
    #
    # @seealso
    # - https://superuser.com/questions/1017959/
    # - https://askubuntu.com/questions/1379425/
    # """
    [[ -d '/run/systemd/system' ]]
}
