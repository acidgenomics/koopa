#!/usr/bin/env bash

_koopa_activate_antigravity_cli() {
    # The agy background auto-updater replaces the koopa-managed 'bin/agy'
    # symlink with a real binary. Export unconditionally, so that a shell
    # started before 'koopa install antigravity-cli' is covered too.
    # agy accepts 'true' here; '1' does not disable the updater.
    export AGY_CLI_DISABLE_AUTO_UPDATE=true
    return 0
}
