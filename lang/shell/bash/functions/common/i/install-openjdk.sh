#!/usr/bin/env bash

koopa_install_openjdk() {
    koopa_install_app \
        --link-in-bin='bin/jar' \
        --link-in-bin='bin/java' \
        --link-in-bin='bin/javac' \
        --name-fancy='Adoptium Temurin OpenJDK' \
        --name='openjdk' \
        "$@"
}
