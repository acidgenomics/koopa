#!/usr/bin/env bash

main() {
    # """
    # Uninstall Docker.
    # @note Updated 2022-06-17.
    # """
    koopa_rm \
        "${HOME}/Library/Application Scripts/com.docker.helper" \
        "${HOME}/Library/Application Scripts/group.com.docker" \
        "${HOME}/Library/Application Support/Docker Desktop" \
        "${HOME}/Library/Caches/com.docker.docker" \
        "${HOME}/Library/Containers/com.docker.docker" \
        "${HOME}/Library/Group Containers/group.com.docker" \
        "${HOME}/Library/HTTPStorages/com.docker.docker" \
        "${HOME}/Library/HTTPStorages/com.docker.docker.binarycookies" \
        "${HOME}/Library/Logs/Docker Desktop" \
        "${HOME}/Library/Preferences/com.docker.docker.plist" \
        "${HOME}/Library/Preferences/com.electron.docker-frontend.plist" \
        "${HOME}/Library/Preferences/com.electron.dockerdesktop.plist" \
        "${HOME}/Library/Saved Application State/com.electron.docker-frontend.savedState" \
        "${HOME}/Library/Saved Application State/com.electron.dockerdesktop.savedState"
}
