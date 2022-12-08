#!/usr/bin/env bash

# FIXME This currently has a build issue (also reported on 2022-10-10).
# - https://github.com/imsnif/bandwhich/issues/258
# - https://github.com/imsnif/bandwhich/pull/259
# - https://github.com/Homebrew/homebrew-core/blob/master/Formula/bandwhich.rb

main() {
    koopa_install_app_subshell \
        --installer='rust-package' \
        --name='bandwhich' \
        "$@"
}
