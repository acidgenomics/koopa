#!/usr/bin/env bash

koopa_install_openjdk() {
    koopa_install_app \
        --link-in-bin='jar' \
        --link-in-bin='java' \
        --link-in-bin='javac' \
        --name='openjdk' \
        "$@"
}
